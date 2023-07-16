#import "BeaSongSearchViewController.h"

@implementation BeaSongSearchViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageCache = [[NSCache alloc] init];
    self.imageCache.totalCostLimit = 10;

    self.contentContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentContainer.layer.cornerRadius = 8.0;
    self.contentContainer.clipsToBounds = YES;
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentContainer];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00];
    self.searchBar.placeholder = @"Search song, artist, album...";
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.searchBar];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.contentContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.contentContainer.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.contentContainer.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.75],

        [self.searchBar.topAnchor constraintEqualToAnchor:self.contentContainer.topAnchor constant:4],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.contentContainer.bottomAnchor]
    ]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearchWithKeyword:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.searchResults = nil;
    [self.tableView reloadData];
}

- (void)performSearchWithKeyword:(NSString *)keyword {
    NSString *accessToken = [[BeaTokenManager sharedInstance] spotifyAccessToken];
    NSString *query = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=track&limit=10", query];
    NSURL *url = [NSURL URLWithString:apiUrl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[Bea] Error performing search: %@", error);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@"[Bea] Search request failed with status code %ld", (long)httpResponse.statusCode);
            return;
        }

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSArray *tracks = json[@"tracks"][@"items"];
        NSMutableArray *results = [NSMutableArray array];

        for (NSDictionary *track in tracks) {
            NSString *artist = track[@"album"][@"artists"][0][@"name"];
            NSString *artwork = track[@"album"][@"images"][0][@"url"];
            NSString *isrc = track[@"external_ids"][@"isrc"];
            NSString *audioType = track[@"type"];
            NSString *openUrl = track[@"external_urls"][@"spotify"];
            NSString *provider = @"spotify";
            NSString *providerId = track[@"id"];
            NSString *trackName = track[@"name"];
            NSString *visibility = @"public";

            NSDictionary *dict = @{
                @"music" : @{
                    @"artist" : artist,
                    @"artwork" : artwork,
                    @"audioType" : audioType,
                    @"isrc" : isrc,
                    @"openUrl" : openUrl,
                    @"provider" : provider,
                    @"providerId" : providerId,
                    @"track" : trackName,
                    @"visibility" : visibility
                }
            };
            
            [results addObject:dict];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchResults = results;
            [self.tableView reloadData];
        });
    }];

    [dataTask resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];

    UIImageView *artworkImageView;
    UILabel *trackLabel;
    UILabel *artistLabel;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchResultCell"];

        cell.contentView.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00];

        artworkImageView = [[UIImageView alloc] init];
        artworkImageView.translatesAutoresizingMaskIntoConstraints = NO;
        artworkImageView.layer.cornerRadius = 4.0;
        artworkImageView.clipsToBounds = YES;
        artworkImageView.tag = 1;
        [cell.contentView addSubview:artworkImageView];

        trackLabel = [[UILabel alloc] init];
        trackLabel.translatesAutoresizingMaskIntoConstraints = NO;
        trackLabel.font = [UIFont fontWithName:@"Inter" size:17];
        trackLabel.tag = 2;
        [cell.contentView addSubview:trackLabel];

        artistLabel = [[UILabel alloc] init];
        artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
        artistLabel.font = [UIFont systemFontOfSize:13];
        artistLabel.tag = 3;
        [cell.contentView addSubview:artistLabel];

        [NSLayoutConstraint activateConstraints:@[
            [artworkImageView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:10],
            [artworkImageView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],
            [artworkImageView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-10],
            [artworkImageView.widthAnchor constraintEqualToConstant:58],
            [artworkImageView.heightAnchor constraintEqualToConstant:58],

            [trackLabel.leadingAnchor constraintEqualToAnchor:artworkImageView.trailingAnchor constant:10],
            [trackLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-10],
            [trackLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:20],

            [artistLabel.leadingAnchor constraintEqualToAnchor:artworkImageView.trailingAnchor constant:10],
            [artistLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-10],
            [artistLabel.topAnchor constraintEqualToAnchor:trackLabel.bottomAnchor constant:5],
            [artistLabel.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-20],
        ]];
    } else {
        artworkImageView = (UIImageView *)[cell.contentView viewWithTag:1];
        trackLabel = (UILabel *)[cell.contentView viewWithTag:2];
        artistLabel = (UILabel *)[cell.contentView viewWithTag:3];
    }

    NSDictionary *searchResult = self.searchResults[indexPath.row][@"music"];

    NSString *artist = searchResult[@"artist"];
    NSString *track = searchResult[@"track"];

    trackLabel.text = track;
    artistLabel.text = artist;

    NSString *imageUrlString = searchResult[@"artwork"];

    // check if the image is already cached
    UIImage *cachedImage = [self.imageCache objectForKey:imageUrlString];
    if (cachedImage) {
        artworkImageView.image = cachedImage;
    } else {
        artworkImageView.image = nil;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *artworkImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]];
            UIImage *artworkImage = [UIImage imageWithData:artworkImageData];

            // cache the downloaded image
            if (artworkImage) {
                [self.imageCache setObject:artworkImage forKey:imageUrlString];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                // ensure that the cell is visible and only then update it
                if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView transitionWithView:artworkImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            artworkImageView.image = artworkImage;
                        } completion:nil];
                    });
                }
            });
        });
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *results = self.searchResults[indexPath.row];
    [[BeaMusicManager sharedInstance] updateCurrentlyPlaying:results];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopUpdatingCurrentlyPlaying" object:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end