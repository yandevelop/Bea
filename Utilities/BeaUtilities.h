@interface BeaButton : UIButton
+ (instancetype)downloadButton;
+ (void)toggleDownloadButtonVisibility:(UIView *)view gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface BeaDownloader : NSObject
+ (void)downloadImage:(id)sender;
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@interface BeaAlertView : UIView
- (void)updateButtonTapped;
- (void)closeButtonTapped;
@end