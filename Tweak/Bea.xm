#import "Bea.h"
#import <RemoteLog.h>

static NSString *realPeopleVC = @"_TtGC7SwiftUI19UIHostingControllerV35OfficialAccountsFanFeedPresentation27OfficialAccountsFanFeedView_";
static NSString *corporateContentVC = @"_TtGC7SwiftUI19UIHostingControllerV26AccountProfilePresentation33OfficialAccountProfileCoordinator_";

%hook DoublePhotoView
%property (nonatomic, strong) BeaButton *downloadButton;
%property (nonatomic, assign) BOOL didUnblur;

- (void)drawRect:(CGRect)rect {
	%orig;

	UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    UIViewController *vc = (UIViewController *)responder;
    
    if ((![vc isKindOfClass:NSClassFromString(corporateContentVC)] && ![vc isKindOfClass:NSClassFromString(realPeopleVC)] && ![vc isKindOfClass:NSClassFromString(@"BeReal.SUIFeedViewController")] && ![vc isKindOfClass:NSClassFromString(@"BeReal.FeedViewController")] && ![vc isKindOfClass:NSClassFromString(@"BeReal.MemoryDetailsViewController")]) || CGRectGetWidth([self frame]) < 180) return;
    
    if ([self downloadButton]) return;

    BeaButton *downloadButton = [BeaButton downloadButton];
    downloadButton.layer.zPosition = 99;

    [self setDownloadButton:downloadButton];
    [self addSubview:downloadButton];


	[NSLayoutConstraint activateConstraints:@[
		[[[self downloadButton] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-11.6],
		[[[self downloadButton] bottomAnchor] constraintEqualToAnchor:[self topAnchor] constant:47.333]
	]];

	if ([self didUnblur]) return;

	// this is a bit hacky but: if the second subview is not a GraphicsView, then the user has
	// access to the unblurred view natively (user already posted BeReal)
	UIView *secondSubview = [[[[self superview] superview] superview] subviews][1];
	if (![NSStringFromClass([secondSubview class]) containsString:@"GraphicsView"]) {
		isUnblurred = YES;
		return;
	}

	[[[self superview] superview] setUserInteractionEnabled:YES];

	for (int i = 1; i < [[[[[self superview] superview] superview] subviews] count]; i++) {
		[[[[[self superview] superview] superview] subviews][i] setHidden:YES];
	}

	[self setDidUnblur:YES];
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

	if ([self.actions count] < 3) return;
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
	// this is kind of a fallback if the normal unblur function somehow fails (BeReal 2.0+)

	if (([arg1 isEqual:@(13)] || [arg1 isEqual:@(8)]) && [self.name isEqual:@"gaussianBlur"]) {
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
        if ([key isEqualToString:@"timelineCell_blurredView_button"] || [key isEqualToString:@"timelineCell_blurredView_description_myFriends"] || [key isEqualToString:@"timelineCell_blurredView_title"] || [key isEqualToString:@"timelineCell_blurredView_description_discoveryGlobal"] || [key isEqualToString:@"roulette_feature_name"] || [key isEqualToString:@"resurrected_user_timeline_card_button"] || [key isEqualToString:@"general_new"]) {
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

%hook RealPeoplePreviewDoublePhotoView
%property (nonatomic, assign) BOOL didUnblur;

- (void)layoutSubviews {
	%orig;

	if ([self didUnblur]) return;
	for (UIView *subview in [[[[[self superview] superview] superview] superview] subviews]) {
		if ([subview subviews].count == 0) {
			[subview setHidden:YES];
		}
	}

	[self setDidUnblur:YES];
}
%end

// idea to get reference to BeReal.DebugMenuLaunchHandler
// get static memory address offset from BeReal binary and base address
// calculate the address of the BeReal.DebugMenuLaunchHandler by adding the offset to the base address on runtime
// then call the function

// update: this is not possible because BeReal.DebugMenuLaunchHandler is locked behind a Resolver.RecursiveLock object

%ctor {
	char *mediaClass = [BeaViewResolver mediaClass];

	%init(
      DoublePhotoView = objc_getClass(mediaClass),
      SettingsViewController = objc_getClass("BeReal.SettingsViewController"),
	  HomeViewController = objc_getClass("BeReal.HomeViewController"),
	  RealPeoplePreviewDoublePhotoView = objc_getClass("_TtCV14RealComponents22DoubleMediaViewSwiftUI23PrimaryImageGestureView"));

	#ifdef JAILED
		initSideloadedFixes();
	#endif
}