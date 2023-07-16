@interface BeaButton : UIButton
+ (instancetype)downloadButton;
- (void)toggleVisibilityWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface BeaDownloader : NSObject
+ (void)downloadImage:(id)sender;
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@interface BeaAlertView : UIView
- (void)updateButtonTapped;
- (void)closeButtonTapped;
@end