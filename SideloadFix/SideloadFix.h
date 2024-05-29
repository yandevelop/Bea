#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import "fishhook/fishhook.h"
#import <objc/runtime.h>
#import <dlfcn.h>

#define BR_BUNDLE_ID @"AlexisBarreyat.BeReal"
#define BR_NAME @"BeReal."

@interface NSFileManager (SideloadedFixes)
- (NSURL*)swizzled_containerURLForSecurityApplicationGroupIdentifier:(NSString*)groupIdentifier;
@end