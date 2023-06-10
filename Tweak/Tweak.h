#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Utilities/BeaUtilities.m"
#import "../Utilities/UploadViewController/BeaUploadViewController.m"
#import <rootless.h>

BOOL isUnblurred = NO;
NSString *authorizationKey = nil;
Class photoView;

@interface CAFilter : NSObject
@property (copy) NSString * name;
@end