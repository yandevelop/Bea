#import "Tweak.h"

%hook DoublePhotoView
%property (nonatomic, strong) BeaButton *downloadButton;

- (void)drawRect:(CGRect)rect {
	%orig;

	UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    UIViewController *vc = (UIViewController *)responder;
    
    if ((![vc isKindOfClass:NSClassFromString(@"BeReal.SUIFeedViewController")] && ![vc isKindOfClass:NSClassFromString(@"BeReal.FeedViewController")] && ![vc isKindOfClass:NSClassFromString(@"BeReal.MemoryDetailsViewController")]) || CGRectGetWidth([self frame]) < 180) return;
    
    if ([self downloadButton]) return;


	[[self superview] setUserInteractionEnabled:YES];
	[[[self superview] superview] setUserInteractionEnabled:YES];

    BeaButton *downloadButton = [BeaButton downloadButton];
    downloadButton.layer.zPosition = 3;

    [self setDownloadButton:downloadButton];
    [self addSubview:downloadButton];

	[NSLayoutConstraint activateConstraints:@[
		[[[self downloadButton] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-11.6],
		[[[self downloadButton] bottomAnchor] constraintEqualToAnchor:[self topAnchor] constant:47.333]
	]];
}


- (void)onMainImagePressed:(UILongPressGestureRecognizer *)gestureRecognizer {
	%orig;
    [[self downloadButton] toggleVisibilityWithGestureRecognizer:gestureRecognizer];
}

- (void)handleMainPanned:(UIPinchGestureRecognizer *)gestureRecognizer {
	%orig;
	[[self downloadButton] toggleVisibilityWithGestureRecognizer:gestureRecognizer];
}

- (void)handleMainPinched:(UIPinchGestureRecognizer *)gestureRecognizer {
	%orig;
	[[self downloadButton] toggleVisibilityWithGestureRecognizer:gestureRecognizer];
}
%end


%hook UIAlertController
- (void)viewWillAppear:(id)arg1 {
	%orig;
    if (isUnblurred) return;
	
    if ([self.actions[2].title isEqual:@"👀 Unblur"]) {
		// Set the whole view to hidden
        self.view.superview.hidden = YES;
		UIAlertAction *thirdAction = self.actions[2];
		id block = [thirdAction valueForKey:@"_handler"];
		if (block) {
			dispatch_async(dispatch_get_main_queue(), ^{
				void (^handler)(UIAlertAction *) = block;
				handler(thirdAction);
			});
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

	if (!isUnblurred && [self respondsToSelector:@selector(openDebugMenu)]) {
		//[homeViewController performSelector:@selector(openDebugMenu)];
		#ifndef LEGACY_SUPPORT
			NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
			NSComparisonResult result = [version compare:@"1.1.2" options:NSNumericSearch];
			if (result == NSOrderedAscending) { 
				BeaAlertView *alertView = [[BeaAlertView alloc] init];
				[[self view] addSubview:alertView];
			}
		#endif
	}

	#ifdef JAILED
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Bea" ofType:@"bundle"];
		NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
		UIImage *beFakeLogo = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"BeFake" ofType:@"png"]];
	#else
		NSBundle *bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Bea.bundle")];
		UIImage *beFakeLogo = [UIImage imageNamed:@"BeFake.png" inBundle:bundle compatibleWithTraitCollection:nil];
	#endif

	CGSize targetSize = [[[self ibNavBarLogoImageView] image] size];

	UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
	[beFakeLogo drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	
	[[self ibNavBarLogoImageView] addGestureRecognizer:tapGestureRecognizer];
	[[self ibNavBarLogoImageView] setImage:resizedImage];
	[[self ibNavBarLogoImageView] setUserInteractionEnabled:YES];
}

%new
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
	// display the error view here
	if (!authorizationKey) return;

	BeaUploadViewController *beaUploadViewController = [[BeaUploadViewController alloc] init];
	beaUploadViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:beaUploadViewController animated:YES completion:nil];
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

	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[self tableView] frame].size.width, 50)];
	NSString *headerText = [NSString stringWithFormat:@"Bea %@\nmade with ❤️ by yan", TWEAK_VERSION];
	headerLabel.text = headerText;
	headerLabel.numberOfLines = 0;
	headerLabel.font = [UIFont fontWithName:@"Inter" size:10];
	headerLabel.textAlignment = NSTextAlignmentCenter;

	[[self tableView] setTableHeaderView:headerLabel];
}
%end


%hook UIScreen
- (BOOL)isCaptured {
	return NO;
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
		[[BeaTokenManager sharedInstance] setBRAccessToken:authorizationKey];
	}
}
%end

%hook UIHostingView
- (void)layoutSubviews {
	%orig;
	for (UIView *v in [[self superview] subviews]) {
		CGFloat width = v.frame.size.width;
		if ((width <= 48 && width > 32) || ([v isKindOfClass:[UIView class]] && width > 350 && width < 1400 && v.subviews.count == 0)) {
			[v setHidden:YES];
		}
	}
}
%end


%hook UIPageViewController
- (void)viewWillAppear:(id)arg1 {
	%orig;
	if ([self.viewControllers.firstObject isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")] && [self.parentViewController isKindOfClass:objc_getClass("BeReal.HomeViewController")] && !isUnblurred) {
		HomeViewController *controller = (HomeViewController *)self.parentViewController;
		[controller openDebugMenu];
	}
}
%end

%ctor {
	#ifdef LEGACY_SUPPORT
		photoView = objc_getClass("BeReal.DoublePhotoView");
	#else
		photoView = objc_getClass("RealComponents.DoublePhotoView");
	#endif

	%init(HomeViewController = objc_getClass("BeReal.HomeViewController"),
      DoublePhotoView = photoView,
      SettingsViewController = objc_getClass("BeReal.SettingsViewController"),
      UIHostingView = objc_getClass("_TtC7SwiftUIP33_A34643117F00277B93DEBAB70EC0697116_UIInheritedView"));
}