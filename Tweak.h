#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *lateBeRealTitle;

@interface BeaButton : UIButton
+ (instancetype)downloadButton;
+ (instancetype)lateBeRealButton:(id)target;
@end

@interface BeaDownloader : NSObject
+ (void)downloadImage:(id)sender;
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end