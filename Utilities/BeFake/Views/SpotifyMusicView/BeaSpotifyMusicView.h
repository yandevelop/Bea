@interface BeaSpotifyMusicView : UIView <BeaSpotifyAPIHandlerDelegate>
@property (nonatomic, strong) UIImageView *artworkImageView;
@property (nonatomic, strong) UILabel *trackLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) NSDictionary *musicDict;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BeaSpotifyAPIHandler *handler;
- (void)refreshMusicView;
@end