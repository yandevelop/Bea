#import "BeaDownloader.h"
#import <Photos/Photos.h>

@implementation BeaDownloader
+ (void)downloadImage:(id)sender {
	UIButton *button = (UIButton *)sender;
	UIImageView *imageView = nil;

    NSString *viewClass;

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (@available(iOS 15.0, *)) {
        // Device is running iOS version 15 or above
        NSComparisonResult versionComparisonResult = [version compare:@"1.12" options:NSNumericSearch];
        if (versionComparisonResult == NSOrderedAscending) {
            // < "1.12"
            viewClass = @"RealComponents.DoublePhotoView";
        } else {
            NSComparisonResult additionalVersionCheckResult = [version compare:@"1.16" options:NSNumericSearch];
            if (additionalVersionCheckResult == NSOrderedAscending) {
                // < 1.16
                viewClass = @"RealComponents.DoubleMediaView";
            } else {
                UIView *hostView;
                if ([version compare:@"1.19.0" options:NSNumericSearch]) {
                    // > 1.16 < 1.18
                    hostView = button.superview.superview.superview;
                }

                // > 1.18.0
                hostView = button.superview.superview.superview.superview;

                UIView *nestedSubview = hostView.subviews.firstObject;

                if (nestedSubview.alpha == 0) {
                    imageView = hostView.subviews[5].subviews[0].subviews[0].subviews[0];
                    //imageView = [self findImageViewInViewHierarchy:hostView];
                } else {
                    imageView = nestedSubview.subviews[0].subviews[0].subviews[0];
                   // imageView = [self findImageViewInViewHierarchy:nestedSubview];
                }
            }
        }
    } else {
        viewClass = @"RealComponents.DoubleMediaView";
    }

    if (!imageView) {
        UIView *tableContentView = button.superview.superview;
        for (UIView *view in tableContentView.subviews) {
            if ([NSStringFromClass([view class]) isEqualToString:viewClass]) {
                imageView = view.subviews.firstObject;
                break;
            }
        }
    }


	if (imageView) {
		UIImage *imageToSave = imageView.image;
		UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)button);
	}
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"[Bea]Error saving image: %@", error.localizedDescription);
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