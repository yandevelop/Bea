#import "Bea.h"

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

    BeaButton *downloadButton = [BeaButton downloadButton];
    downloadButton.layer.zPosition = 99;

    [self setDownloadButton:downloadButton];
    [self addSubview:downloadButton];


	[NSLayoutConstraint activateConstraints:@[
		[[[self downloadButton] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-11.6],
		[[[self downloadButton] bottomAnchor] constraintEqualToAnchor:[self topAnchor] constant:47.333]
	]];

	// backwards compatibility: if the user has a newer version of BeReal installed,
	// the native unblur function doesnt exist and the the download button must be hidden manually
	// if we remove this check on older version, this will effectively hide the whole DoublePhotoView because
	// the native unblur function already removed all unneccessary views and the last object becomes the
	// DoublePhotoView
	if (isUnblurred) return;
	// hide the "Post late button"
	[[[[[[[self superview] superview] superview] superview] superview] subviews] lastObject].hidden = YES;
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
- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	// return early here because otherwise the app will crash on other alert controllers
	// trying to access the 2nd index of the actions array which is (probably) not present
	if (isUnblurred) return;

	if ([self.actions[2].title isEqual:@"👀 Unblur"]) {
		self.view.superview.hidden = YES;
		UIAlertAction *thirdAction = self.actions[2];
		id block = [thirdAction valueForKey:@"_handler"];
		if (block) {
			dispatch_async(dispatch_get_main_queue(), ^{
				void (^handler)(UIAlertAction *) = block;
				handler(thirdAction);
			});
			isUnblurred = YES;
		}
		[self dismissViewControllerAnimated:NO completion:nil];
	}
}
%end


%hook HomeViewController
- (void)viewDidLoad {
	%orig;

	UIStackView *stackView = (UIStackView *)[[self ibNavBarLogoImageView] superview];
	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.alignment = UIStackViewAlignmentCenter;
	
	UIImageView *plusImage = [[UIImageView alloc] init];
	plusImage.image = [UIImage systemImageNamed:@"plus.app"];
	plusImage.translatesAutoresizingMaskIntoConstraints = NO;

	[stackView addArrangedSubview:plusImage];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[stackView addGestureRecognizer:tapGestureRecognizer];
	[stackView setUserInteractionEnabled:YES];
}

%new
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
	// display the error view here
	if (![[BeaTokenManager sharedInstance] BRAccessToken]) return;

	BeaUploadViewController *beaUploadViewController = [[BeaUploadViewController alloc] init];
	beaUploadViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:beaUploadViewController animated:YES completion:nil];
}
%end


%hook CAFilter
-(void)setValue:(id)arg1 forKey:(id)arg2 {
	if (isUnblurred) return %orig;
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


%hook NSBundle
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	// since BeReal 1.4 the bundleIdentifier seems to have changed. Keeping both for backwards compatibility
	if (!isUnblurred & [self.bundleIdentifier isEqualToString:@"Localisation-Localisation-resources"] || [self.bundleIdentifier isEqualToString:@"com.bereal.BRAssets"]) {
        if ([key isEqualToString:@"timelineCell_blurredView_button"] || [key isEqualToString:@"timelineCell_blurredView_description_myFriends"] || [key isEqualToString:@"timelineCell_blurredView_title"] || [key isEqualToString:@"timelineCell_blurredView_description_discoveryGlobal"]) {
            return @"";
        }
	}
    return %orig;
}
%end


%hook NSMutableURLRequest
-(void)setAllHTTPHeaderFields:(NSDictionary *)arg1 {
	%orig;

	if ([[arg1 allKeys] containsObject:@"Authorization"] && [[arg1 allKeys] containsObject:@"bereal-device-id"] && !headers) {
		if ([arg1[@"Authorization"] length] > 0) {
			headers = (NSDictionary *)arg1;
			[[BeaTokenManager sharedInstance] setHeaders:headers];
		}
	} 
}
%end


%hook UIHostingView
-(void)setUserInteractionEnabled:(BOOL)arg1 {
	if (isUnblurred) return %orig(arg1);
	%orig(YES);
}

- (void)layoutSubviews {
	%orig;
	if (isUnblurred) return;
	for (UIView *v in [[self superview] subviews]) {
		CGFloat width = v.frame.size.width;
		if ((width <= 49 && width > 32) || ([v isKindOfClass:[UIView class]] && width > 350 && width < 1400 && v.subviews.count == 0)) {
			[v setHidden:YES];
		}
	}
}
%end


%hook UIPageViewController
- (void)viewDidLoad {
	%orig;
	if (isUnblurred) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([self.viewControllers.firstObject isKindOfClass:objc_getClass("BeReal.SUIFeedViewController")] && [self.parentViewController respondsToSelector:@selector(openDebugMenu)] && [self.parentViewController isKindOfClass:objc_getClass("BeReal.HomeViewController")]) {
			HomeViewController *controller = (HomeViewController *)self.parentViewController;
			[controller openDebugMenu];
		}
	});
}
%end

%ctor {
	char *mediaClass = [BeaViewResolver mediaClass];

	%init(
      DoublePhotoView = objc_getClass(mediaClass),
      SettingsViewController = objc_getClass("BeReal.SettingsViewController"),
      UIHostingView = objc_getClass("_TtC7SwiftUIP33_A34643117F00277B93DEBAB70EC0697116_UIInheritedView"),
	  HomeViewController = objc_getClass("BeReal.HomeViewController"));

	#ifdef JAILED
		initSideloadedFixes();
	#endif
}