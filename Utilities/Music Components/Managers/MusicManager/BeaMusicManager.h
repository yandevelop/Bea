@interface BeaMusicManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *musicDict;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *track;
@property (nonatomic, assign) NSInteger playingStatus;
+ (instancetype)sharedInstance;
- (void)updateCurrentlyPlaying:(NSDictionary *)musicDict;
- (void)setMusicVisibility:(NSString *)visibility;
@end