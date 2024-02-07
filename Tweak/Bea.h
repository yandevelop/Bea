#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utilities/Helpers/Helpers.h"
#import "../Utilities/Managers/TokenManager/BeaTokenManager.m"
#import "../Utilities/BeFake/ViewControllers/UploadViewController/BeaUploadViewController.m"

BOOL isUnblurred = NO;
NSDictionary *headers;

@interface CAFilter : NSObject
@property (copy) NSString *name;
@end

@interface DoublePhotoView : UIView
@property (nonatomic, strong) BeaButton *downloadButton;
@end

@interface HomeViewController : UIViewController
@property (nonatomic, retain) UIImageView *ibNavBarLogoImageView;
- (void)openDebugMenu;
@end

@interface SettingsViewController : UIViewController
@property (nonatomic, retain) UITableView *tableView;
@end

@interface UIHostingView : UIView
@end

#ifdef JAILED
#import "SideloadFix/SideloadedFixes.mm"
#endif