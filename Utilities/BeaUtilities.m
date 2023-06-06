#import "BeaUtilities.h"

@implementation BeaDownloader
+ (void)downloadImage:(id)sender {
	UIButton *button = (UIButton *)sender;
	UIView *tableContentView = button.superview.superview;
	UIImageView *imageView = nil;

    #ifdef LEGACY_SUPPORT
        NSString *viewClass = @"BeReal.DoublePhotoView";
    #else
        NSString *viewClass = @"RealComponents.DoublePhotoView";
    #endif

	for (UIView *view in tableContentView.subviews) {
		if ([NSStringFromClass([view class]) isEqualToString:viewClass]) {
			imageView = view.subviews.firstObject;
			break;
		}
	}
	if (imageView) {
		UIImage *imageToSave = imageView.image;
		UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)button);
	}
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"Error saving image: %@", error.localizedDescription);
    } else {
        UIButton *button = (__bridge UIButton *)contextInfo;
		UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:19];
		UIImage *checkmarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:config];
		[UIView transitionWithView:button duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[button setImage:checkmarkImage forState:UIControlStateNormal];
		[button setEnabled:NO]; 
		[button.imageView setTintColor:[UIColor colorWithRed:122.0/255.0 green:255.0/255.0 blue:108.0/255.0 alpha:1.0]];} completion:nil];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			UIImage *downloadImage = [UIImage systemImageNamed:@"arrow.down.circle.fill" withConfiguration:config];
			[UIView transitionWithView:button duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
				[button setImage:downloadImage forState:UIControlStateNormal];
				[button.imageView setTintColor:[UIColor whiteColor]];
				[button setEnabled:YES];
			} completion:nil];
        });
    }
}
@end

@implementation BeaButton
+ (instancetype)downloadButton {
    BeaButton *downloadButton = [BeaButton buttonWithType:UIButtonTypeRoundedRect];
    [downloadButton setTitle:@"" forState:UIControlStateNormal];

	UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:19];
	UIImage *downloadImage = [UIImage systemImageNamed:@"arrow.down.circle.fill" withConfiguration:config];
	downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	downloadButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    downloadButton.layer.shadowOffset = CGSizeMake(0, 0);
    downloadButton.layer.shadowRadius = 3;
    downloadButton.layer.shadowOpacity = 0.5;

    [downloadButton setImage:downloadImage forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    [downloadButton sizeToFit];
	downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [downloadButton addTarget:[BeaDownloader class] action:@selector(downloadImage:) forControlEvents:UIControlEventTouchUpInside];
    
    return downloadButton;
}
@end

@implementation BeaAlertView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAlertView];
    }
    return self;
}

- (void)setupAlertView {
    self.frame = [UIScreen mainScreen].bounds;
    
    UIView *shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    shadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha: 0.5];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTapped)];
    [shadeView addGestureRecognizer:tapGesture];
    [self addSubview:shadeView];

    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 240)];
    box.backgroundColor = [UIColor blackColor];
    box.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds)); 
    box.layer.cornerRadius = 8.0;
    [self addSubview:box];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(box.frame), 30)];
    titleLabel.text = @"Version unsupported";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Inter" size:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame) + 5, CGRectGetWidth(box.frame) - 60, 85)];
    messageLabel.text = @"The current app version is no longer supported.\nUpdate the app or downgrade the tweak to continue using it.";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont fontWithName:@"Inter" size:15];

    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    updateButton.frame = CGRectMake(40, CGRectGetMaxY(messageLabel.frame) + 20, box.frame.size.width - 80, 40);
    updateButton.layer.cornerRadius = 6.0;
    updateButton.titleLabel.font = [UIFont fontWithName:@"Inter" size:16];
    updateButton.backgroundColor = [UIColor whiteColor];
    [updateButton setTitle:@"Update" forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(updateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(box.frame.size.width - 44, 6, 40, 40);
    closeButton.titleLabel.font = [UIFont fontWithName:@"Inter" size:16];
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [box addSubview:closeButton];
    [box addSubview:updateButton];
    [box addSubview:titleLabel];
    [box addSubview:messageLabel];
}

- (void)updateButtonTapped {
    NSString *appStoreLink = @"https://apps.apple.com/app/id1459645446";
    NSURL *appStoreURL = [NSURL URLWithString:appStoreLink];

    if ([[UIApplication sharedApplication] canOpenURL:appStoreURL]) {
        [[UIApplication sharedApplication] openURL:appStoreURL options:@{} completionHandler:nil];
    }
}

- (void)closeButtonTapped {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end