#import <CoreLocation/CoreLocation.h>
#import <rootless.h>
#import "StatusView/BeaStatusView.m"
#import "../InfoViewController/BeaInfoViewController.m"
#import "../UploadTask/BeaUploadTask.m"
#import "../LocationViewController/BeaLocationViewController.m"

@interface BeaUploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, BeaLocationViewControllerDelegate>
@property (nonatomic, strong) BeaLocationViewController *locationVC;
@property (nonatomic, strong) NSString *authorizationKey;
@property (nonatomic, strong) UIImageView *frontImageView;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *frontTextLabel;
@property (nonatomic, strong) UILabel *backTextLabel;
@property (nonatomic, strong) UIImage *frontImage;
@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UITextField *captionTextField;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UITextField *retakeTextField;
@property (nonatomic, strong) NSNumber *retakeCount;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) BeaStatusView *statusView;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *backButtonImageView;
@property (nonatomic, strong) UISwitch *isLateSwitch;
@property (nonatomic, strong) UILabel *isLateLabel;
@property (nonatomic, assign) BOOL isLate;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIImageView *infoButtonImageView;
@end