@protocol BeaSpotifyAPIHandlerDelegate <NSObject>
- (void)managerDidValidateAccessToken;
@end

@interface BeaSpotifyAPIHandler : NSObject
@property (nonatomic, weak) id<BeaSpotifyAPIHandlerDelegate> delegate;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSNumber *expiryValue;
- (void)retrieveCurrentlyPlayingSong;
@end