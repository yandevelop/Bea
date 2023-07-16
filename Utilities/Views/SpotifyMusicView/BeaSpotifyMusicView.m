#import "BeaSpotifyMusicView.h"

@implementation BeaSpotifyMusicView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMusicView) name:@"MusicUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimer) name:@"StopUpdatingCurrentlyPlaying" object:nil];

        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.artworkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.artworkImageView.layer.cornerRadius = 1.0;
        self.artworkImageView.clipsToBounds = YES;
        [self addSubview:self.artworkImageView];

        // set up the properties for the artist and track label
        self.trackLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.trackLabel.font = [UIFont fontWithName:@"Inter" size:17];
        self.trackLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.trackLabel];

        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.artistLabel.font = [UIFont systemFontOfSize:12];
        self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.artistLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.artworkImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [self.artworkImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.artworkImageView.widthAnchor constraintEqualToConstant:36],
            [self.artworkImageView.heightAnchor constraintEqualToConstant:36],
            
            [self.trackLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:2],
            [self.trackLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
            [self.trackLabel.trailingAnchor constraintEqualToAnchor:self.artworkImageView.leadingAnchor constant:-12],

            [self.artistLabel.topAnchor constraintEqualToAnchor:self.trackLabel.bottomAnchor constant:2],
            [self.artistLabel.leadingAnchor constraintEqualToAnchor:self.trackLabel.leadingAnchor],
            [self.artistLabel.widthAnchor constraintLessThanOrEqualToConstant:125],
        ]];

        self.handler = [[BeaSpotifyAPIHandler alloc] init];
        self.handler.delegate = self;
    }

    return self;
}

- (void)managerDidValidateAccessToken {
    [self startFetchingSongs];
}

- (void)startFetchingSongs {
    // add a gesture recognizer to the view that opens the spotify modal
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSpotifyViewController)];
    [self addGestureRecognizer:self.tapRecognizer];
    [self.handler retrieveCurrentlyPlayingSong];
    [self startTimer];
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self.handler selector:@selector(retrieveCurrentlyPlayingSong) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)openSpotifyViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openSpotifyViewController" object:nil];
}

- (void)refreshMusicView {
    self.musicDict = [[BeaMusicManager sharedInstance] musicDict];

    NSData *artworkImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.musicDict[@"music"][@"artwork"]]];
    UIImage *artworkImage = [UIImage imageWithData:artworkImageData];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.trackLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.trackLabel.text = self.musicDict[@"music"][@"track"];
        } completion:nil];
        
        [UIView transitionWithView:self.artistLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.artistLabel.text = self.musicDict[@"music"][@"artist"];
        } completion:nil];

        [UIView transitionWithView:self.artworkImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.artworkImageView setImage:artworkImage];
        }
        completion:nil];
    });
}
@end