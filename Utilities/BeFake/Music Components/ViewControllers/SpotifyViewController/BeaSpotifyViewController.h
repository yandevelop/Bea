@interface BeaSpotifyViewController : UIViewController
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSDictionary *musicDict;
@property (nonatomic, strong) UIImageView *artworkImageView;
@property (nonatomic, strong) UILabel *trackLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) NSArray<NSDictionary *> *visibilityData;
@property (nonatomic, strong) UIView *visibilityView;
@property (nonatomic, strong) UIImageView *visibilityImageView;
@property (nonatomic, strong) UILabel *visibilityLabel;
@property (nonatomic, strong) UILabel *visibilitySubtitle;
@property (nonatomic, strong) UIImpactFeedbackGenerator *generator;

@property (nonatomic, strong) UIView *searchActionView;
@property (nonatomic, strong) UIImageView *searchIconImageView;
@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) UILabel *searchSubtitle;

@property (nonatomic, strong) BeaSongSearchViewController *songSearchViewController;
- (void)updateArtworkView;
@end