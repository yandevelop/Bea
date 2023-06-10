#import "BeaInfoViewController.h"

@implementation BeaInfoViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    self.wrapperView = [[UIView alloc] init];
    self.wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wrapperView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwitterTap)];
    [self.wrapperView addGestureRecognizer:tapGestureRecognizer];

    self.profileImageView = [[UIImageView alloc] init];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.profileImageView.layer.cornerRadius = 25;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.translatesAutoresizingMaskIntoConstraints = NO;

    NSData *profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://avatars.githubusercontent.com/u/82288425?v=4"]];
    UIImage *profileImage = [UIImage imageWithData:profileImageData];
    self.profileImageView.image = profileImage;
    [self.wrapperView addSubview:self.profileImageView];

    self.smallLabel = [[UILabel alloc] init];
    self.smallLabel.textAlignment = NSTextAlignmentCenter;
    self.smallLabel.textColor = [UIColor whiteColor];
    self.smallLabel.text = @"developed by";
    self.smallLabel.font = [UIFont fontWithName:@"Inter" size:10];
    self.smallLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.wrapperView addSubview:self.smallLabel];

    self.twitterLabel = [[UILabel alloc] init];
    self.twitterLabel.textAlignment = NSTextAlignmentCenter;
    self.twitterLabel.textColor = [UIColor whiteColor];
    self.twitterLabel.font = [UIFont fontWithName:@"Inter" size:18];
    self.twitterLabel.text = @"yandevelop";
    self.twitterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.wrapperView addSubview:self.twitterLabel];

    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.textColor = [UIColor whiteColor];
    self.versionLabel.font = [UIFont fontWithName:@"Inter" size:9];
    NSString *headerText = [NSString stringWithFormat:@"Bea\nVersion %@", TWEAK_VERSION];
    self.versionLabel.text = headerText;
    self.versionLabel.numberOfLines = 0;
    self.versionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.versionLabel];

    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurEffectView];
    [self.view sendSubviewToBack:blurEffectView];

    [self.view addSubview:self.wrapperView];

    [NSLayoutConstraint activateConstraints:@[
        [self.wrapperView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.wrapperView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.wrapperView.widthAnchor constraintEqualToConstant:125],
        [self.wrapperView.heightAnchor constraintEqualToConstant:100],

        [self.profileImageView.centerXAnchor constraintEqualToAnchor:self.wrapperView.centerXAnchor],
        [self.profileImageView.widthAnchor constraintEqualToConstant:50],
        [self.profileImageView.heightAnchor constraintEqualToConstant:50],

        [self.smallLabel.centerXAnchor constraintEqualToAnchor:self.wrapperView.centerXAnchor],
        [self.smallLabel.topAnchor constraintEqualToAnchor:self.profileImageView.bottomAnchor constant:10],

        [self.twitterLabel.centerXAnchor constraintEqualToAnchor:self.wrapperView.centerXAnchor],
        [self.twitterLabel.topAnchor constraintEqualToAnchor:self.smallLabel.bottomAnchor],

        [self.versionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.versionLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)handleTwitterTap {
    NSURL *twitterWebURL = [NSURL URLWithString:@"https://twitter.com/yandevelop"];
    [[UIApplication sharedApplication] openURL:twitterWebURL options:@{} completionHandler:nil];
}
@end