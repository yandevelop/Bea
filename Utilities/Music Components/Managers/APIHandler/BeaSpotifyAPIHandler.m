#import "BeaSpotifyAPIHandler.h"

@implementation BeaSpotifyAPIHandler
- (instancetype)init {
    self = [super init];
    if (self) {
        [self validateAccessToken];
    }
    return self;
}


- (void)validateAccessToken {
    [[BeaTokenManager sharedInstance] retrieveCredentials];

    self.expiryValue = [[BeaTokenManager sharedInstance] expiryValue];
    
    NSDate *now = [NSDate date];
    NSTimeInterval nowTimestamp = [now timeIntervalSinceReferenceDate];

    NSTimeInterval expireTimestamp = [self.expiryValue doubleValue];

    // check if the access token already expired
    if (nowTimestamp > expireTimestamp) {
        [self refreshSpotifyAccessToken];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate managerDidValidateAccessToken];
        });
    }
}

- (void)refreshSpotifyAccessToken {
    // to refresh the access token, a call to bereals api endpoint has to be made
    // this will return a new access token that we can use to fetch the currently playing song

    self.refreshToken = [[BeaTokenManager sharedInstance] spotifyRefreshToken];
    NSString *BRAccessToken = [[BeaTokenManager sharedInstance] BRAccessToken];

    if (!self.refreshToken) return;

    NSString *baseRefreshURL = @"https://mobile.bereal.com/api/music/spotify/refresh_token";
    NSString *refreshURLString = [NSString stringWithFormat:@"%@?refresh_token=%@", baseRefreshURL, self.refreshToken];
    NSURL *refreshURL = [NSURL URLWithString:refreshURLString];

    NSMutableURLRequest *refreshTokenRequest = [NSMutableURLRequest requestWithURL:refreshURL];
    [refreshTokenRequest setHTTPMethod:@"GET"];

    NSDictionary *headers = @{
        @"authorization": BRAccessToken,
        @"accept": @"*/*",
        @"bereal-platform": @"iOS",
        @"bereal-os-version": @"14.7.1",
        @"accept-Language": @"en-US;q=1.0",
        @"user-Agent": @"BeReal/1.7.0 (AlexisBarreyat.BeReal; build:11001; iOS 14.7.1) 1.0.0/BRApiKit",
        @"bereal-app-language": @"en-US",
        @"bereal-device-language": @"en",
        @"bereal-app-version" : @"1.7.0-(11001)"
    };

    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        [refreshTokenRequest setValue:value forHTTPHeaderField:field];
    }];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:refreshTokenRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.accessToken = jsonResponse[@"accessToken"];

                // update the access tokens in the keychain to avoid future unneccesary api calls
                [[BeaTokenManager sharedInstance] writeToKeychainWithDictionary:jsonResponse];

                // notify the delegate that the manager now validated the access token
                [self.delegate managerDidValidateAccessToken];
            } else {
                NSLog(@"[Bea] Error! %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }];
    [task resume];
}

- (void)retrieveCurrentlyPlayingSong {
    // since the delegate is called from the main thread and thus this function also
    // enter the background thread again

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // check if the access token is nil since it's possible that it hasn't been set before
        if (!self.accessToken) {
            self.accessToken = [[BeaTokenManager sharedInstance] spotifyAccessToken];
        }

        NSString *currentlyPlayingURLString = @"https://api.spotify.com/v1/me/player/currently-playing?additional_types=episode";    
        NSURL *currentlyPlayingURL = [NSURL URLWithString:currentlyPlayingURLString];

        NSMutableURLRequest *currentlyPlayingRequest = [NSMutableURLRequest requestWithURL:currentlyPlayingURL];
        [currentlyPlayingRequest setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionDataTask *currentlyPlayingTask = [[NSURLSession sharedSession] dataTaskWithRequest:currentlyPlayingRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 204 || data.length == 0) {
                NSDictionary *musicDict = @{
                    @"music" : @{
                        @"artist" : @"",
                        @"track" : @"No music playing"
                    }
                };

                [[BeaMusicManager sharedInstance] updateCurrentlyPlaying:musicDict];
                return;
            }
            
            if (error) {
                NSLog(@"[Bea] Error retrieving currently playing song: %@", error.localizedDescription);
                return;
            }
            
            if (httpResponse.statusCode == 401) {
                NSDictionary *musicDict = @{
                    @"music" : @{
                        @"artist" : @"",
                        @"track" : @"Access token expired"
                    }
                };

                [[BeaMusicManager sharedInstance] updateCurrentlyPlaying:musicDict];
                [self refreshSpotifyAccessToken];
                NSLog(@"[Bea] Error: Access token expired %ld", (long)httpResponse.statusCode);
                return;
            }

            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSString *audioType = jsonResponse[@"currently_playing_type"];

            NSString *artist;
            NSString *artwork;
            NSString *isrc;

            if ([audioType isEqual:@"episode"]) {
                artist = jsonResponse[@"item"][@"show"][@"publisher"];
                artwork = jsonResponse[@"item"][@"images"][0][@"url"];
                isrc = @"";
            } else {
                artist = jsonResponse[@"item"][@"artists"][0][@"name"];
                artwork = jsonResponse[@"item"][@"album"][@"images"][0][@"url"];
                isrc = jsonResponse[@"item"][@"external_ids"][@"isrc"];
            }

            NSString *openUrl = jsonResponse[@"item"][@"external_urls"][@"spotify"];
            NSString *provider = @"spotify";

            NSString *providerId = jsonResponse[@"item"][@"id"];
            NSString *track = jsonResponse[@"item"][@"name"];
            NSString *visibility = @"public";

            NSDictionary *musicDict = @{
                @"music" : @{
                    @"artist" : artist,
                    @"artwork" : artwork,
                    @"audioType" : audioType,
                    @"isrc" : isrc,
                    @"openUrl" : openUrl,
                    @"provider" : provider,
                    @"providerId" : providerId,
                    @"track" : track,
                    @"visibility" : visibility
                }
            };

            [[BeaMusicManager sharedInstance] updateCurrentlyPlaying:musicDict];
        }];
        
        [currentlyPlayingTask resume]; 
    });
}
@end
