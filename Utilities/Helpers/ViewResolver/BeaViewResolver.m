#import "BeaViewResolver.h"

@implementation BeaViewResolver
+ (char *)mediaClass {

    char *className;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (@available(iOS 15.0, *)) {
        // Device is running iOS version 15 or above
        NSComparisonResult versionComparisonResult = [version compare:@"1.12" options:NSNumericSearch];
        if (versionComparisonResult == NSOrderedAscending) {
            // < "1.12"
            className = (char *)"RealComponents.DoublePhotoView";
        } else {
            NSComparisonResult additionalVersionCheckResult = [version compare:@"1.16" options:NSNumericSearch];
            if (additionalVersionCheckResult == NSOrderedAscending) {
                // < 1.16
                className = (char *)"RealComponents.DoubleMediaView";
            } else {
                // > 1.16
                className = (char *)"_TtCV14RealComponents18NewDoubleMediaView23PrimaryImageGestureView";
            }
        }
    } else {
        className = (char *)"RealComponents.DoubleMediaView";
    }
    return className;
}
@end