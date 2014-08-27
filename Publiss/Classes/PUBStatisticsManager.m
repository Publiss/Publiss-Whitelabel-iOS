//
//  PUBStatisticsManager.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBStatisticsManager.h"
#import "Lockbox.h"
#import "PUBConstants.h"
#import <PublissCore.h>

@interface PUBStatisticsManager ()
@property (strong, nonatomic) NSMutableArray *cachedStatisticsStore;
@end


@implementation PUBStatisticsManager

+ (instancetype)sharedInstance {
    static PUBStatisticsManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{_manager = [PUBStatisticsManager new]; });
    return _manager;
}

- (id)init {
    if ((self = [super init])) {
        NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
        [dnc addObserver:self selector:@selector(receivedAppStartNotification:) name:PUBApplicationDidStartNotification object:nil];
        [dnc addObserver:self selector:@selector(receivedDocumentOpenNotification:) name:PUBDocumentDidOpenNotification object:nil];
        [dnc addObserver:self selector:@selector(receivedDocumentDownloadNotification:) name:PUBDocumentDownloadNotification object:nil];
        [dnc addObserver:self selector:@selector(receivedTrackedPageNotification:) name:PUBDocumentPageTrackedNotification object:nil];
        [dnc addObserver:self selector:@selector(receivedDeletedDocumentNotification:) name:PUBStatisticsDocumentDeletedNotification object:nil];
    }
    return self;
}

#pragma mark - Public API

- (NSString *)appID {
    NSString *appID = [Lockbox stringForKey:PUBStatisticsAppIDKey];

    if (!appID) {
        NSUUID *vendorID = [UIDevice currentDevice].identifierForVendor;
        NSString *key = [NSString stringWithFormat:@"%@_%@", vendorID.UUIDString, @(NSTimeIntervalSince1970)];
        [Lockbox setString:key forKey:PUBStatisticsAppIDKey];
        appID = [Lockbox stringForKey:PUBStatisticsAppIDKey];
    }
    return appID;
}


- (NSArray *)cachedStatistics {
    return [NSUserDefaults.standardUserDefaults arrayForKey:PUBStatisticsUserDefaultsKey];
}


- (void)clearCache {
    if ([_cachedStatisticsStore count]) {
        [_cachedStatisticsStore removeAllObjects];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:PUBStatisticsUserDefaultsKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

#pragma mark - Getter & Setter

- (NSMutableArray *)cachedStatisticsStore {
    if (!_cachedStatisticsStore) {
        _cachedStatisticsStore = [NSMutableArray array];

        NSArray *statsFromDefaults = [NSUserDefaults.standardUserDefaults arrayForKey:PUBStatisticsUserDefaultsKey];
        if ([statsFromDefaults count]) {
            _cachedStatisticsStore = [NSMutableArray arrayWithArray:statsFromDefaults];
        }
    }
    return _cachedStatisticsStore;
}

#pragma mark - Notification Selectors

- (void)receivedAppStartNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        PUBLogVerbose(@"%@ receivedAppStartNotification: %@", self.class, notification.userInfo);
        NSMutableDictionary *appStartStatistics = [NSMutableDictionary dictionaryWithDictionary:notification.userInfo];
        [appStartStatistics removeObjectForKey:PUBStatisticsAppIDKey];
        [self addEventToCachedStatistics:appStartStatistics];
    }
}

- (void)receivedDocumentOpenNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        PUBLogVerbose(@"%@ receivedDocumentOpenNotification: %@", self.class, notification.userInfo);
        [self addEventToCachedStatistics:notification.userInfo];
    }
}

- (void)receivedDocumentDownloadNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        PUBLogVerbose(@"%@ receivedDocumentDownloadNotification: %@", self.class, notification.userInfo);
        [self addEventToCachedStatistics:notification.userInfo];
    }
}

- (void)receivedTrackedPageNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        PUBLogVerbose(@"%@ added page tracking information: %@", self.class, notification.userInfo);
        [self addEventToCachedStatistics:notification.userInfo];
    }
}

- (void)receivedDeletedDocumentNotification:(NSNotification *)notification {
    if (notification.userInfo) {
        PUBLogVerbose(@"receivedFetchedPageNotification : %@", notification.userInfo);
        [self addEventToCachedStatistics:notification.userInfo];
    }
}

#pragma helper

- (void)addEventToCachedStatistics:(NSDictionary*)dictionary {
    [self.cachedStatisticsStore addObject:dictionary];
    [NSUserDefaults.standardUserDefaults setObject:[self.cachedStatisticsStore copy] forKey:PUBStatisticsUserDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}




@end
