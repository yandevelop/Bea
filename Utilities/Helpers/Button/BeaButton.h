@interface BeaButton : UIButton
+ (instancetype)downloadButton;
- (void)toggleVisibilityWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end