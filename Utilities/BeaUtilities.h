@interface BeaButton : UIButton
+ (instancetype)downloadButton;
@end

@interface BeaDownloader : NSObject
+ (void)downloadImage:(id)sender;
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@interface BeaAlertView : UIView
- (void)updateButtonTapped;
- (void)closeButtonTapped;
@end