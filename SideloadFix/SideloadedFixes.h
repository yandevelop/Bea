#import <mach-o/dyld.h>
#import "fishhook/fishhook.h"
#import <objc/runtime.h>

@interface NSFileManager (SideloadedFixes)
- (NSURL*)swizzled_containerURLForSecurityApplicationGroupIdentifier:(NSString*)groupIdentifier;
@end