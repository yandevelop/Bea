#import "Tweak.h"

%hook DoublePhotoView
- (void)layoutSubviews {
	%orig;

	UIView *doublePhotoView = (UIView *)self;
	if ([doublePhotoView.subviews.lastObject isKindOfClass:[BeaButton class]] || doublePhotoView.frame.size.width < 180) return;

	UIResponder *responder = self;
	while (responder && ![responder isKindOfClass:[UIViewController class]]) {
		responder = [responder nextResponder];
	}
	UIViewController *vc = (UIViewController *)responder;
	
	if (![vc isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")]) return;

	BeaButton *downloadButton = [BeaButton downloadButton];
	[doublePhotoView addSubview:downloadButton];
	downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[downloadButton.trailingAnchor constraintEqualToAnchor:doublePhotoView.trailingAnchor constant:-11.6],
		[downloadButton.bottomAnchor constraintEqualToAnchor:doublePhotoView.topAnchor constant:47.333]
	]];
}
%end

%hook UIAlertController
- (void)viewDidLoad {
	UIAlertController *alertController = (UIAlertController *)self;
	%orig;
	
	if (![alertController.presentingViewController isKindOfClass:objc_getClass("BeReal.NavigationController")]) return %orig;
	UIAlertAction *thirdAction = alertController.actions[2];
	id block = [thirdAction valueForKey:@"_handler"];
	if (block) {
		void (^handler)(UIAlertAction *) = block;
		handler(thirdAction);
		isUnblurred = YES;
	}
}

- (void)viewWillAppear:(id)arg1 {
	%orig;
	if ([self.presentingViewController isKindOfClass:objc_getClass("BeReal.NavigationController")] || [self.presentingViewController isKindOfClass:[UINavigationController class]]) {
		// Set the whole view to hidden
		self.view.superview.hidden = YES;

		// Dismiss the UIAlertController automatically
		[self dismissViewControllerAnimated:NO completion:nil];
	}
}
%end

%hook HomeViewController
- (void)viewDidLoad {
    %orig;
    UIViewController *homeViewController = (UIViewController *)self;

    if (!isUnblurred && [homeViewController respondsToSelector:@selector(openDebugMenu)] && [homeViewController.childViewControllers.lastObject isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")]) {
       [homeViewController performSelector:@selector(openDebugMenu)];

		NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSComparisonResult result = [version compare:@"1.1.2" options:NSNumericSearch];
		if (result == NSOrderedAscending) { 
			BeaAlertView *alertView = [[BeaAlertView alloc] init];
			[homeViewController.view addSubview:alertView];
		}
    }
}
%end

%hook SwiftView
- (void)layoutSubviews {
	%orig;
	UIView *s = (UIView *)self;
	// removes the eye view and the post late button from the blurred view
	for (UIView *v in s.subviews) {
		if (v.frame.size.width <= 48 && v.frame.size.width > 32) {
			v.hidden = YES;
		}
		if (([v isKindOfClass:objc_getClass("SwiftUI._UIGraphicsView")] || [v isKindOfClass:[UIView class]]) && v.frame.size.width > 350 && v.subviews.count == 0) {
			v.hidden = YES;
		}
	}
}
%end

%hook CALayer
- (void)setFilters:(NSArray *)filter {
	return;
}
%end

%hook SettingsViewController
- (void)viewDidLoad {
	%orig;

	UIViewController *vc = (UIViewController *)self;
	UITableView *labelView = vc.view.subviews.firstObject;
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelView.frame.size.width, 50)];
	headerLabel.text = @"Bea 1.1.2\nmade with ❤️ by yan";
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
    if ([self.bundleIdentifier isEqualToString:@"com.bereal.BRAssets"]) {
        if ([key isEqualToString:@"timelineCell_blurredView_button"] || [key isEqualToString:@"timelineCell_blurredView_description_myFriends"] || [key isEqualToString:@"timelineCell_blurredView_title"]) {
            return nil;
        }
	}
    return %orig;
}
%end


%ctor {
	%init(HomeViewController = objc_getClass("_TtC6BeReal18HomeViewController"),
	DoublePhotoView = objc_getClass("RealComponents.DoublePhotoView"),
	SettingsViewController = objc_getClass("_TtC6BeReal22SettingsViewController"),
	SwiftView = objc_getClass("_TtCC7SwiftUI17HostingScrollView22PlatformGroupContainer"));

	// Enable dualCamera?
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"debug_dualCameraPreviewEnabled"];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"debug_developerModeEnabled"];
}