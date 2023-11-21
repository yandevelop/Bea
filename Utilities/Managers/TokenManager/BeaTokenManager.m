#import "BeaTokenManager.h"

@implementation BeaTokenManager
+ (instancetype)sharedInstance {
    static BeaTokenManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)BRAccessToken {
    _BRAccessToken = self.headers[@"Authorization"];
    return _BRAccessToken;
}

- (void)retrieveCredentials {
    NSString *serviceName = @"com.bereal.BRMusic";
    NSString *accountName = @"Spotify.AuthStore.credentials";
    NSString *groupName = @"group.BeReal";

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: serviceName,
        (__bridge id)kSecAttrAccount: accountName,
        (__bridge id)kSecAttrAccessGroup: groupName,
        (__bridge id)kSecReturnData: @YES
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status == errSecSuccess) {
        NSData *credentialData = (__bridge_transfer NSData *)result;
        NSDictionary *credentials = [NSJSONSerialization JSONObjectWithData:credentialData options:0 error:nil];

        self.spotifyAccessToken = credentials[@"accessToken"];
        self.spotifyRefreshToken = credentials[@"refreshToken"];
        self.expiryValue = credentials[@"expiry"];

    } else if (status == errSecItemNotFound) {
        NSLog(@"[Bea] Keychain item not found for the specified service and account.");
    } else {
        NSLog(@"[Bea] Keychain error: %d", (int)status);
    }
}

// update the keychain with the new access token and a new expiry value
- (void)writeToKeychainWithDictionary:(NSDictionary *)response {
    NSString *serviceName = @"com.bereal.BRMusic";
    NSString *accountName = @"Spotify.AuthStore.credentials";
    NSString *groupName = @"group.BeReal";

    NSDate *now = [NSDate date];
    NSTimeInterval oneHour = 3600;
    NSDate *expireDate = [now dateByAddingTimeInterval:oneHour];
    NSTimeInterval expiryInterval = [expireDate timeIntervalSinceReferenceDate];
    NSNumber *expiryValue = [NSNumber numberWithDouble:expiryInterval];

    NSString *accessToken = response[@"accessToken"];
    NSString *refreshToken = self.spotifyRefreshToken;
    self.spotifyAccessToken = accessToken;

    NSDictionary *credentials = @{
        @"accessToken": accessToken,
        @"refreshToken": refreshToken,
        @"expiry" : expiryValue
    };

    NSData *credentialData = [NSJSONSerialization dataWithJSONObject:credentials options:0 error:nil];

    NSDictionary *searchQuery = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: serviceName,
        (__bridge id)kSecAttrAccount: accountName,
        (__bridge id)kSecAttrAccessGroup: groupName
    };

    NSDictionary *updateQuery = @{
        (__bridge id)kSecValueData: credentialData
    };

    OSStatus searchStatus = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, NULL);

    if (searchStatus == errSecSuccess) {
        OSStatus updateStatus = SecItemUpdate((__bridge CFDictionaryRef)searchQuery, (__bridge CFDictionaryRef)updateQuery);

        if (updateStatus == errSecSuccess) {
            NSLog(@"[Bea] Data successfully updated in the keychain.");
        } else {
            NSLog(@"[Bea] Failed to update data in the keychain. Error: %d", (int)updateStatus);
        }
    } else {
        NSLog(@"[Bea] Keychain item not found for the specified service, account, and group.");
    }
}
@end