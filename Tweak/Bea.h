#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utilities/Helpers/Helpers.h"
#import "../Utilities/Managers/TokenManager/BeaTokenManager.m"
#import "../Utilities/BeFake/ViewControllers/UploadViewController/BeaUploadViewController.m"
#import <substrate.h>
#import <objc/runtime.h>

template <typename Type_>
static inline Type_ &MSHookSwiftIvar(id self, const char *classSymbol, const char *name) {
    Ivar ivar(class_getInstanceVariable(objc_getClass(classSymbol), name));
    void *pointer = ivar == NULL ? NULL : (void *)((uintptr_t)self + ivar_getOffset(ivar));
    return *reinterpret_cast<Type_ *>(pointer);
}

BOOL isUnblurred = NO;
NSDictionary *headers;

@interface CAFilter : NSObject
@property (copy) NSString *name;
@end

@interface DoublePhotoView : UIView
@property (nonatomic, strong) BeaButton *downloadButton;
@property (nonatomic, assign) BOOL didUnblur;
@end

@interface HomeViewController : UIViewController
@property (nonatomic, retain) UIImageView *ibNavBarLogoImageView;
- (void)openDebugMenu;
@end

@interface SettingsViewController : UIViewController
@property (nonatomic, retain) UITableView *tableView;
@end

@interface UIHostingView : UIView
@property (nonatomic, assign) BOOL didUnblur;
@end

#ifdef JAILED
#import "SideloadFix/SideloadedFixes.mm"
#endif