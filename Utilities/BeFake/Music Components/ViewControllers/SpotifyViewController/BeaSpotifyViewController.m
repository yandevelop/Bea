#import "BeaSpotifyViewController.h"

@implementation BeaSpotifyViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.visibilityData = @[
        @{@"label": @"Shared", @"subtitle": @"Visible to your friends", @"image": @"person.2.fill", @"value" : @"public"},
        @{@"label": @"Private", @"subtitle": @"Only visible to you", @"image": @"lock.fill", @"value" : @"private"},
        @{@"label": @"Disabled", @"subtitle": @"Don't add what you're listening to", @"image": @"play.slash", @"value" : @"none"}
    ];

    self.songSearchViewController = [[BeaSongSearchViewController alloc] init];
    self.generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];

    [self setupArtworkView];
    [self setupVisibilityView];
    [self setupSearchActionView];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.contentContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.contentContainer.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.contentContainer.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.7],

        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentContainer.topAnchor constant:22],
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.contentContainer.centerXAnchor],

        [self.artworkImageView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:18],
        [self.artworkImageView.centerXAnchor constraintEqualToAnchor:self.contentContainer.centerXAnchor],
        [self.artworkImageView.widthAnchor constraintEqualToConstant:134],
        [self.artworkImageView.heightAnchor constraintEqualToConstant:134],

        [self.trackLabel.topAnchor constraintEqualToAnchor:self.artworkImageView.bottomAnchor constant:18],
        [self.trackLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentContainer.leadingAnchor constant:22],
        [self.trackLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentContainer.trailingAnchor constant:-22],
        [self.trackLabel.centerXAnchor constraintEqualToAnchor:self.contentContainer.centerXAnchor],
        [self.trackLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.contentContainer.widthAnchor constant:-44],

        [self.artistLabel.topAnchor constraintEqualToAnchor:self.trackLabel.bottomAnchor constant:2],
        [self.artistLabel.centerXAnchor constraintEqualToAnchor:self.contentContainer.centerXAnchor],

        [self.visibilityView.topAnchor constraintEqualToAnchor:self.artistLabel.bottomAnchor constant:18],
        [self.visibilityView.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor constant:18],
        [self.visibilityView.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor constant:-18],
        [self.visibilityView.widthAnchor constraintEqualToAnchor:self.contentContainer.widthAnchor constant:-36],
        [self.visibilityView.heightAnchor constraintEqualToConstant:55],

        [self.visibilityImageView.centerYAnchor constraintEqualToAnchor:self.visibilityView.centerYAnchor],
        [self.visibilityImageView.leadingAnchor constraintEqualToAnchor:self.visibilityView.leadingAnchor constant:14],
        [self.visibilityImageView.widthAnchor constraintEqualToConstant:24],
        [self.visibilityImageView.heightAnchor constraintEqualToConstant:24],

        [self.visibilityLabel.topAnchor constraintEqualToAnchor:self.visibilityView.topAnchor constant:10],
        [self.visibilityLabel.leadingAnchor constraintEqualToAnchor:self.visibilityImageView.trailingAnchor constant:9],

        [self.visibilitySubtitle.topAnchor constraintEqualToAnchor:self.visibilityLabel.bottomAnchor],
        [self.visibilitySubtitle.leadingAnchor constraintEqualToAnchor:self.visibilityLabel.leadingAnchor],

        [self.searchActionView.topAnchor constraintEqualToAnchor:self.visibilityView.bottomAnchor constant:12],
        [self.searchActionView.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor constant:18],
        [self.searchActionView.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor constant:-18],
        [self.searchActionView.widthAnchor constraintEqualToAnchor:self.contentContainer.widthAnchor constant:-36],
        [self.searchActionView.heightAnchor constraintEqualToAnchor:self.visibilityView.heightAnchor],

        [self.searchIconImageView.centerYAnchor constraintEqualToAnchor:self.searchActionView.centerYAnchor],
        [self.searchIconImageView.leadingAnchor constraintEqualToAnchor:self.searchActionView.leadingAnchor constant:14],
        [self.searchIconImageView.widthAnchor constraintEqualToConstant:24],
        [self.searchIconImageView.heightAnchor constraintEqualToConstant:24],

        [self.searchLabel.topAnchor constraintEqualToAnchor:self.searchActionView.topAnchor constant:10],
        [self.searchLabel.leadingAnchor constraintEqualToAnchor:self.visibilityLabel.leadingAnchor],

        [self.searchSubtitle.topAnchor constraintEqualToAnchor:self.searchLabel.bottomAnchor],
        [self.searchSubtitle.leadingAnchor constraintEqualToAnchor:self.searchLabel.leadingAnchor]
    ]];
    
    [self updateMusicData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMusicData) name:@"MusicUpdated" object:nil];
}

- (void)updateMusicData {
    self.musicDict = [[BeaMusicManager sharedInstance] musicDict];
    [self updateArtworkView];
}

- (void)setupArtworkView {
    self.contentContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentContainer.layer.cornerRadius = 8.0;
    self.contentContainer.clipsToBounds = YES;
    self.contentContainer.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:0.97];
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentContainer];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Currently playing";
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont fontWithName:@"Inter" size:22];
    [self.contentContainer addSubview:self.titleLabel];

    self.artworkImageView = [[UIImageView alloc] init];
    self.artworkImageView.layer.cornerRadius = 4.0;
    self.artworkImageView.clipsToBounds = YES;
    self.artworkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.artworkImageView];

    self.trackLabel = [[UILabel alloc] init];
    self.trackLabel.font = [UIFont fontWithName:@"Inter" size:20];
    self.trackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.trackLabel];

    self.artistLabel = [[UILabel alloc] init];
    self.artistLabel.font = [UIFont fontWithName:@"Inter" size:12];
    self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.artistLabel];
}

- (void)setupSearchActionView {
    self.searchActionView = [[UIView alloc] init];
    self.searchActionView.backgroundColor = [UIColor whiteColor];
    self.searchActionView.layer.cornerRadius = 12.0;
    self.searchActionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.searchActionView];

    self.searchIconImageView = [[UIImageView alloc] init];
    self.searchIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.searchIconImageView.clipsToBounds = YES;
    self.searchIconImageView.image = [[UIImage systemImageNamed:@"magnifyingglass"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.searchIconImageView.tintColor = [UIColor blackColor];
    self.searchIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchActionView addSubview:self.searchIconImageView];

    self.searchLabel = [[UILabel alloc] init];
    self.searchLabel.text = @"Search";
    self.searchLabel.font = [UIFont fontWithName:@"Inter" size:16];
    self.searchLabel.textColor = [UIColor blackColor];
    self.searchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchActionView addSubview:self.searchLabel];
    
    self.searchSubtitle = [[UILabel alloc] init];
    self.searchSubtitle.text = @"Search for another song";
    self.searchSubtitle.font = [UIFont systemFontOfSize:12];
    self.searchSubtitle.textColor = [UIColor blackColor];
    self.searchSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchActionView addSubview:self.searchSubtitle];

    UITapGestureRecognizer *searchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchViewTapped)];
    [self.searchActionView addGestureRecognizer:searchGestureRecognizer];
}

- (void)setupVisibilityView {
    self.visibilityView = [[UIView alloc] init];
    self.visibilityView.backgroundColor = [UIColor whiteColor];
    self.visibilityView.layer.cornerRadius = 12.0;
    self.visibilityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentContainer addSubview:self.visibilityView];

    self.visibilityImageView = [[UIImageView alloc] init];
    self.visibilityImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.visibilityImageView.clipsToBounds = YES;

    UIImage *visibilityImage = [[UIImage systemImageNamed:self.visibilityData[0][@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.visibilityImageView.image = visibilityImage;

    self.visibilityImageView.tintColor = [UIColor blackColor];
    self.visibilityImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.visibilityView addSubview:self.visibilityImageView];

    self.visibilityLabel = [[UILabel alloc] init];
    self.visibilityLabel.text = self.visibilityData[0][@"label"];
    self.visibilityLabel.font = [UIFont fontWithName:@"Inter" size:16];
    self.visibilityLabel.textColor = [UIColor blackColor];
    self.visibilityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.visibilityView addSubview:self.visibilityLabel];
    
    self.visibilitySubtitle = [[UILabel alloc] init];
    self.visibilitySubtitle.text = self.visibilityData[0][@"subtitle"];
    self.visibilitySubtitle.font = [UIFont systemFontOfSize:12];
    self.visibilitySubtitle.textColor = [UIColor blackColor];
    self.visibilitySubtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.visibilityView addSubview:self.visibilitySubtitle];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(visibilityViewTapped)];
    [self.visibilityView addGestureRecognizer:tapRecognizer];
}

- (void)searchViewTapped {
    [UIView animateWithDuration:0.15 animations:^{
        self.searchActionView.transform = CGAffineTransformMakeScale(0.98, 0.98);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.searchActionView.transform = CGAffineTransformIdentity;
        }];
    }];

    [self.generator prepare];
    [self.generator impactOccurred];

    [self presentViewController:self.songSearchViewController animated:YES completion:nil];
}

- (void)updateArtworkView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *artworkImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.musicDict[@"music"][@"artwork"]]];
        UIImage *artworkImage = [UIImage imageWithData:artworkImageData];

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:self.artworkImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.artworkImageView.image = artworkImage;
            } completion:nil];
        });
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.artistLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.artistLabel.text = self.musicDict[@"music"][@"artist"];
        } completion:nil];

        [UIView transitionWithView:self.trackLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.trackLabel.text = self.musicDict[@"music"][@"track"];
        } completion:nil];
    });
}

- (void)visibilityViewTapped {
    static NSInteger currentIndex = 1;
    NSDictionary *currentItem = self.visibilityData[currentIndex];

    [UIView animateWithDuration:0.15 animations:^{
        self.visibilityView.transform = CGAffineTransformMakeScale(0.98, 0.98);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.visibilityView.transform = CGAffineTransformIdentity;
        }];
    }];

    [self.generator prepare];
    [self.generator impactOccurred];

    self.visibilityLabel.text = currentItem[@"label"];
    self.visibilitySubtitle.text = currentItem[@"subtitle"];
    self.visibilityImageView.image = [UIImage systemImageNamed:currentItem[@"image"]];

    // update the object that holds the current playing info
    [[BeaMusicManager sharedInstance] setMusicVisibility:currentItem[@"value"]];
    
    currentIndex = (currentIndex + 1) % self.visibilityData.count;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MusicUpdated" object:nil];
}
@end