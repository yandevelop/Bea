#import "Tweak.h"

%hook DoublePhotoView
- (void)layoutSubviews {
	%orig;

	UIView *doublePhotoView = (UIView *)self;

	if ([doublePhotoView.subviews.lastObject isKindOfClass:[BeaButton class]] || doublePhotoView.frame.size.width < 180) return;

	// make the view accept touches (dragging photos etc)
	doublePhotoView.superview.userInteractionEnabled = YES;
	doublePhotoView.superview.superview.userInteractionEnabled = YES;

	UIResponder *responder = self;
	while (responder && ![responder isKindOfClass:[UIViewController class]]) {
		responder = [responder nextResponder];
	}
	UIViewController *vc = (UIViewController *)responder;
	
	if (![vc isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")] && ![vc isKindOfClass:objc_getClass("BeReal.FeedViewController")]) return;

	BeaButton *downloadButton = [BeaButton downloadButton];
	[doublePhotoView addSubview:downloadButton];

	[NSLayoutConstraint activateConstraints:@[
		[downloadButton.trailingAnchor constraintEqualToAnchor:doublePhotoView.trailingAnchor constant:-11.6],
		[downloadButton.bottomAnchor constraintEqualToAnchor:doublePhotoView.topAnchor constant:47.333]
	]];
}

- (void)onMainImagePressed:(UILongPressGestureRecognizer *)gestureRecognizer {
	%orig;
    [BeaButton toggleDownloadButtonVisibility:self gestureRecognizer:gestureRecognizer];
}


- (void)handleMainPanned:(UIPinchGestureRecognizer *)gestureRecognizer {
	%orig;
	[BeaButton toggleDownloadButtonVisibility:self gestureRecognizer:gestureRecognizer];
}

- (void)handleMainPinched:(UIPinchGestureRecognizer *)gestureRecognizer {
	%orig;
	[BeaButton toggleDownloadButtonVisibility:self gestureRecognizer:gestureRecognizer];
}
%end


%hook UIAlertController
- (void)viewWillAppear:(id)arg1 {
	%orig;
    if (isUnblurred) return;
	
    UIAlertController *alertController = (UIAlertController *)self;
    if ([alertController.actions[2].title isEqual:@"👀 Unblur"]) {
		// Set the whole view to hidden
        self.view.superview.hidden = YES;
		UIAlertAction *thirdAction = alertController.actions[2];
		id block = [thirdAction valueForKey:@"_handler"];
		if (block) {
			void (^handler)(UIAlertAction *) = block;
			handler(thirdAction);
		}
		isUnblurred = YES;
		// Dismiss the UIAlertController automatically
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
%end


%hook HomeViewController
- (void)viewDidLoad {
	%orig;

	UIViewController *homeViewController = (UIViewController *)self;

	if (!isUnblurred && [homeViewController respondsToSelector:@selector(openDebugMenu)]) {
		//[homeViewController performSelector:@selector(openDebugMenu)];
		#ifndef LEGACY_SUPPORT
			NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
			NSComparisonResult result = [version compare:@"1.1.2" options:NSNumericSearch];
			if (result == NSOrderedAscending) { 
				BeaAlertView *alertView = [[BeaAlertView alloc] init];
				[homeViewController.view addSubview:alertView];
			}
		#endif
	}

	UIImageView *beRealLogoView = [self valueForKey:@"ibNavBarLogoImageView"];
	beRealLogoView.userInteractionEnabled = YES;

	#ifdef JAILED
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Bea" ofType:@"bundle"];
		NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
		UIImage *beFakeLogo = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"BeFake" ofType:@"png"]];
	#else
		NSBundle *bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Bea.bundle")];
		UIImage *beFakeLogo = [UIImage imageNamed:@"BeFake.png" inBundle:bundle compatibleWithTraitCollection:nil];
	#endif

	CGSize targetSize = beRealLogoView.image.size;

	UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
	[beFakeLogo drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	beRealLogoView.image = resizedImage;

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[beRealLogoView addGestureRecognizer:tapGestureRecognizer];
}

%new
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {

	UIViewController *vc = (UIViewController *)self;
	// display the error view here
	if (!authorizationKey) return;

	BeaUploadViewController *beaUploadViewController = [[BeaUploadViewController alloc] initWithAuthorization:authorizationKey];
	beaUploadViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	[vc presentViewController:beaUploadViewController animated:YES completion:nil];
}
%end


%hook CAFilter
-(void)setValue:(id)arg1 forKey:(id)arg2 {
    // remove the blur that gets applied to the BeReals
	// this is kind of a fallback if the normal unblur function somehow fails
	if ([arg1 isEqual:@(13)] && [self.name isEqual:@"gaussianBlur"]) {
		return %orig(0, arg2);
	}
    %orig;
}
%end


%hook SettingsViewController
- (void)viewDidLoad {
	%orig;

	UIViewController *vc = (UIViewController *)self;
	UITableView *labelView = vc.view.subviews.firstObject;
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelView.frame.size.width, 50)];
	NSString *headerText = [NSString stringWithFormat:@"Bea %@\nmade with ❤️ by yan", TWEAK_VERSION];
	headerLabel.text = headerText;
	headerLabel.numberOfLines = 0;
	headerLabel.font = [UIFont fontWithName:@"Inter" size:10];
	headerLabel.textAlignment = NSTextAlignmentCenter;
	labelView.tableHeaderView = headerLabel;
}
%end


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

// return a nil string so the BeReal photo view is clear :)
%hook NSBundle
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	
	// since BeReal 1.4 the bundleIdentifier seems to have changed. Keeping both for backwards compatibility
	if ([self.bundleIdentifier isEqualToString:@"Localisation-Localisation-resources"] || [self.bundleIdentifier isEqualToString:@"com.bereal.BRAssets"]) {
        if ([key isEqualToString:@"timelineCell_blurredView_button"] || [key isEqualToString:@"timelineCell_blurredView_description_myFriends"] || [key isEqualToString:@"timelineCell_blurredView_title"] || [key isEqualToString:@"timelineCell_blurredView_description_discoveryGlobal"]) {
            return nil;
        }
	}
    return %orig;
}
%end


%hook NSMutableURLRequest
-(void)setAllHTTPHeaderFields:(NSDictionary *)arg1 {
	%orig;
	if ([[arg1 allKeys] containsObject:@"Authorization"] && !authorizationKey) {
		authorizationKey = arg1[@"Authorization"];
	}
}
%end


%hook UIHostingView
- (void)layoutSubviews {
	%orig;
	UIView *s = (UIView *)self;
	for (UIView *v in s.superview.subviews) {
		if ((v.frame.size.width <= 48 && v.frame.size.width > 32) || (([v isKindOfClass:objc_getClass("SwiftUI._UIGraphicsView")] || [v isKindOfClass:[UIView class]]) && v.frame.size.width > 350 && v.subviews.count == 0)) {
			v.hidden = YES;
		}
	}
}
%end


%hook UIPageViewController
- (void)viewWillAppear:(id)arg1 {
	%orig;
	if ([self.viewControllers.firstObject isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")] && [self.parentViewController isKindOfClass:objc_getClass("BeReal.HomeViewController")] && !isUnblurred) {
		[self.parentViewController performSelector:@selector(openDebugMenu)];
	}
}
%end

%ctor {
	#ifdef LEGACY_SUPPORT
		photoView = objc_getClass("BeReal.DoublePhotoView");
	#else
		photoView = objc_getClass("RealComponents.DoublePhotoView");
	#endif

	%init(HomeViewController = objc_getClass("_TtC6BeReal18HomeViewController"),
      DoublePhotoView = photoView,
      SettingsViewController = objc_getClass("_TtC6BeReal22SettingsViewController"),
      UIHostingView = objc_getClass("_TtC7SwiftUIP33_A34643117F00277B93DEBAB70EC0697116_UIInheritedView"));
}