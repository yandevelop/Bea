#import "BeaMusicManager.h"

@implementation BeaMusicManager
+ (instancetype)sharedInstance {
    static BeaMusicManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)updateCurrentlyPlaying:(NSDictionary *)musicDict {
    if ([self.musicDict isEqual:musicDict]) return;

    self.musicDict = [musicDict mutableCopy];

    if ([musicDict[@"music"][@"artist"] isEqual:@""] || [musicDict[@"music"][@"track"] isEqual:@""]) {
        [self setPlayingStatus:0];
    } else {
        [self setPlayingStatus:1];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicUpdated" object:nil];
}



- (void)setMusicVisibility:(NSString *)visibility {
    if ([visibility isEqual:@"none"]) {
        self.musicDict = nil;
        return;
    }

    NSMutableDictionary *mutableMusicDict = [self.musicDict[@"music"] mutableCopy];
    [mutableMusicDict setValue:visibility forKey:@"visibility"];
    [self.musicDict setObject:mutableMusicDict forKey:@"music"];
}

- (void)resetData {
    self.musicDict = nil;
    self.artist = nil;
    self.track = nil;
}
@end