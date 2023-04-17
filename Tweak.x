#import "Tweak.h"

@implementation BeaDownloader
+ (void)downloadImage:(id)sender {
	UIButton *button = (UIButton *)sender;
	UIView *tableContentView = button.superview.superview;
	UIImageView *imageView = nil;
	for (UIView *view in tableContentView.subviews) {
		if ([NSStringFromClass([view class]) isEqualToString:@"BeReal.DoublePhotoView"]) {
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
		UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22];
		UIImage *checkmarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:config];
		[UIView transitionWithView:button duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[button setImage:checkmarkImage forState:UIControlStateNormal];
		[button setEnabled:NO]; 
		[button.imageView setTintColor:[UIColor colorWithRed:122.0/255.0 green:255.0/255.0 blue:108.0/255.0 alpha:1.0]];} completion:nil];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

	UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22];
	UIImage *downloadImage = [UIImage systemImageNamed:@"arrow.down.circle.fill" withConfiguration:config];
	downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	downloadButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    downloadButton.layer.shadowOffset = CGSizeMake(0, 0);
    downloadButton.layer.shadowRadius = 3;
    downloadButton.layer.shadowOpacity = 0.7;

    [downloadButton setImage:downloadImage forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    [downloadButton sizeToFit];
	downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [downloadButton addTarget:[BeaDownloader class] action:@selector(downloadImage:) forControlEvents:UIControlEventTouchUpInside];
    
    return downloadButton;
}

+ (instancetype)lateBeRealButton:(id)target {
    BeaButton *lateBeRealButton = [BeaButton buttonWithType:UIButtonTypeSystem];
    NSString *title = lateBeRealTitle ?: @"Post a Late BeReal.";
    [lateBeRealButton setTitle:title forState:UIControlStateNormal];
    lateBeRealButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
    lateBeRealButton.layer.cornerRadius = 8;
    lateBeRealButton.layer.masksToBounds = YES;
    lateBeRealButton.tintColor = [UIColor blackColor];
    lateBeRealButton.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightBold];
    [lateBeRealButton sizeToFit];

    [NSLayoutConstraint activateConstraints:@[[lateBeRealButton.titleLabel.leadingAnchor constraintEqualToAnchor:lateBeRealButton.leadingAnchor constant: 12],
    [lateBeRealButton.titleLabel.topAnchor constraintEqualToAnchor:lateBeRealButton.topAnchor constant:10],
    [lateBeRealButton.titleLabel.bottomAnchor constraintEqualToAnchor:lateBeRealButton.bottomAnchor constant:-10],
    [lateBeRealButton.heightAnchor constraintEqualToAnchor:lateBeRealButton.titleLabel.heightAnchor constant:20]]];

	[lateBeRealButton addTarget:target action:@selector(emptyViewTakeBeReal) forControlEvents:UIControlEventTouchUpInside];

    lateBeRealButton.translatesAutoresizingMaskIntoConstraints = NO;

    return lateBeRealButton;
}
@end

%hook CameraViewController
// Display the close button even if not finished taking a photo
- (void)viewDidLoad {
	%orig;
	UIViewController *viewController = (UIViewController *)self;
	for (UIView *subview in viewController.view.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
			if (subview.hidden == YES) {
				subview.hidden = NO;
				break;
			}
		}
	}
}

// Don't dismiss if the countdown of 2 minutes finishes
- (void)countdownFinished {
	UIViewController *viewController = (UIViewController *)self;
	for (UILabel *countdownLabel in viewController.view.subviews) {
		if ([countdownLabel isKindOfClass:objc_getClass("_TtC14CountdownLabel14CountdownLabel")]) {
			countdownLabel.text = @"Take your time.";
			countdownLabel.textColor = [UIColor whiteColor];
			[UIView animateWithDuration:0.4 delay:10.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				countdownLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
				[countdownLabel removeFromSuperview];
			}];
		}
	}
}
%end

%hook FriendsViewController
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	%orig;
	if ([cell isKindOfClass:NSClassFromString(@"BeReal.FeedPostCell")]) {
		for (UIView *subview in cell.contentView.subviews) {
			if ([subview isKindOfClass:objc_getClass("_TtC6BeReal20FeedPostCellBlurView")]) {
				if ([subview.superview.subviews[2] isKindOfClass:objc_getClass("_TtC6BeReal15DoublePhotoView")]) {
					// This gets set to hidden if the user already has taken a BeReal, so we won't display a button if that is the case.
					if (subview.hidden == YES) continue; 
					UIView *photoView = subview.superview.subviews[2];
					BeaButton *lateBeRealButton = [BeaButton lateBeRealButton:self];
					[photoView addSubview:lateBeRealButton];
					[NSLayoutConstraint activateConstraints:@[[lateBeRealButton.trailingAnchor constraintEqualToAnchor:photoView.trailingAnchor constant:-11.6],
						[lateBeRealButton.bottomAnchor constraintEqualToAnchor:photoView.topAnchor constant:47.333]
					]];
					[subview removeFromSuperview];
				}
				continue;
			}

			if ([subview isKindOfClass:[UIStackView class]]) {
				// Unhide the comment button
				if (subview.subviews[1].hidden == YES) subview.subviews[1].hidden = NO;
				for (UIButton *button in subview.subviews) {
					if ([button isKindOfClass:[BeaButton class]]) return;
				}
				BeaButton *downloadButton = [BeaButton downloadButton];
				[(UIStackView *)subview insertArrangedSubview:downloadButton atIndex:0];
			}
		}
    }
}
%end

%hook DoublePhotoView
// Hide the buttons on long press
// (somehow i can not get an instance of these in viewDidLoad, since declaring an interface does not work with swift classes)
- (void)onMainImagePressed:(UILongPressGestureRecognizer *)gestureRecognizer {
	%orig;
	UIView *view = (UIView *)self;
	// since DoublePhotoView is reused, the superviews subviews can sometimes only have one entry and this will crash the app
	// we thus have to check if the views superview is UITableViewCellContentView to ensure that we are in Discovery or FeedFriends Controller
	if (![view.superview isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) return;
	//if (![view.superview.subviews[3].subviews.lastObject isKindOfClass:[BeaButton class]]) return;

	BeaButton *lateBeRealButton = view.subviews.lastObject;
	BeaButton *downloadButton = view.superview.subviews[3].subviews.lastObject;
	if (gestureRecognizer.state == 1) {
		[UIView animateWithDuration:0.2 animations:^{
        	lateBeRealButton.alpha = 0;
			downloadButton.alpha = 0;
    	}];
	} else if (gestureRecognizer.state == 3) {
		[UIView animateWithDuration:0.2 animations:^{
        	lateBeRealButton.alpha = 1;
			downloadButton.alpha = 1;
    	}];
	}
}
%end

%hook DiscoveryViewController
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:NSClassFromString(@"BeReal.FeedPostCell")]) {
		for (UIView *subview in cell.contentView.subviews) {
			if ([subview isKindOfClass:objc_getClass("_TtC6BeReal20FeedPostCellBlurView")]) {
				[subview removeFromSuperview];
				continue;
			}
			if ([subview isKindOfClass:[UIStackView class]]) {
				if (subview.subviews[1].hidden == YES) subview.subviews[1].hidden = NO;
				for (UIButton *button in subview.subviews) {
					if ([button isKindOfClass:[BeaButton class]]) return;
				}
				BeaButton *downloadButton = [BeaButton downloadButton];
				[(UIStackView *)subview insertArrangedSubview:downloadButton atIndex:0];
			}
		}
    }
}

%end

// Bypass screenshot detection?
%hook UIScreen
- (BOOL)isCaptured {
	return NO;
}
%end

%hook NSNotificationCenter
- (void)addObserver:(id)arg0 selector:(SEL)arg1 name:(NSNotificationName)arg2 object:(id)arg3 {
   if (arg2 == UIApplicationUserDidTakeScreenshotNotification) {
      return;
   }
   %orig;
}
%end

%ctor {
	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.bereal.BRAssets"];
	lateBeRealTitle = [bundle localizedStringForKey:@"timelineCell_blurredView_button" value:@"" table:@"Localizable"];
	%init(CameraViewController = objc_getClass("_TtC6BeReal20CameraViewController"), FriendsViewController = objc_getClass("_TtC6BeReal25FeedFriendsViewController"), DiscoveryViewController = objc_getClass("_TtC6BeReal18FeedViewController"), DoublePhotoView = objc_getClass("BeReal.DoublePhotoView"));
}