#include <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *lateBeReal;

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

%hook UIView
- (void)layoutSubviews {
	%orig;

	// Get the current View Controller
	UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    UIViewController *vc = (UIViewController *)responder;
	
	// Remove the "Post to view" View
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:objc_getClass("_TtC6BeReal20FeedPostCellBlurView")]) {
			[subview removeFromSuperview];
			break;
		}
	}

	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:objc_getClass("UIImageView")] && [view.superview isKindOfClass:objc_getClass("BeReal.DoublePhotoView")]) {
			for (UIButton *button in view.subviews) {
				if ([button isKindOfClass:[UIButton class]]) {
					return;
				}
			}

			// Adding the "Post a Late BeReal." button but only for the Feed Friends View
			if (![vc isKindOfClass:objc_getClass("_TtC6BeReal25FeedFriendsViewController")] || (vc == nil)) return;
			UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
			button.backgroundColor = [UIColor colorWithWhite: 1.0 alpha: 0.9];
			button.layer.cornerRadius = 8;
			button.layer.masksToBounds = YES;
			button.tintColor = [UIColor blackColor];
			NSString *title = lateBeReal ?: @"Post a Late BeReal.";
			[button setTitle:title forState:UIControlStateNormal];
			button.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightBold];
			[button sizeToFit];
			CGRect frame = button.frame;
			frame.size.width += 20;
			button.frame = CGRectMake(view.frame.size.width - frame.size.width - 10, 11.7, frame.size.width, 36);
			[button addTarget:vc action:@selector(emptyViewTakeBeReal) forControlEvents:UIControlEventTouchUpInside];
			[view addSubview:button];
			break;
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
	lateBeReal = [bundle localizedStringForKey:@"timelineCell_blurredView_button" value:@"" table:@"Localizable"];
	%init(CameraViewController = objc_getClass("_TtC6BeReal20CameraViewController"));
}