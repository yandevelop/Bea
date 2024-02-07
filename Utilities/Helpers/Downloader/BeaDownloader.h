@interface BeaDownloader : NSObject
+ (void)downloadImage:(id)sender;
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end