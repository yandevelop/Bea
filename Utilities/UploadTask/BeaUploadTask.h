#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BeaUploadTask : NSObject
- (instancetype)initWithData:(NSDictionary *)data frontImage:(UIImage *)frontImage backImage:(UIImage *)backImage;
@property (nonatomic, strong) NSString *authorizationKey;
@property (nonatomic, retain) NSData *frontImageData;
@property (nonatomic, retain) NSData *backImageData;
@property (nonatomic, strong) NSDictionary *userDictionary;
@property (nonatomic, strong) NSString *takenAt;
@property (nonatomic, strong) NSString *lastMoment;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSDictionary *headers;
- (void)uploadBeRealWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)makePUTRequestWithData:(NSDictionary *)data completion:(void (^)(BOOL success, NSError *error))completion;
- (void)putPhotoWithURL:(NSURL *)url headers:(NSDictionary *)headers imageData:(NSData *)imageData completion:(void (^)(BOOL success))completion;
- (void)postBeRealWithFrontPath:(NSString *)frontPath backPath:(NSString *)backPath frontBucket:(NSString *)frontBucket backBucket:(NSString *)backBucket completion:(void (^)(BOOL success, NSError *error))completion;
- (void)getLastMoment;
- (void)handleErrorWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(BOOL success, NSError *error))completion;
@end