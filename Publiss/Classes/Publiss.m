//
//  Publiss.m
//  Publiss
//
//  Created by Daniel Griesser on 26.08.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "Publiss.h"
#import "PUBDocument+Helper.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "PUBStatisticsManager.h"
#import "UIColor+PUBDesign.h"
#import "PUBConstants.h"
#import <PublissCore.h>

@implementation Publiss

+ (Publiss *)staticInstance {
    static Publiss *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (void)setupWithLicenseKey:(NSString *)licenseString {
#if defined(PUBClearAllFilesOnAppStart) && PUBClearAllFilesOnAppStart
    // DEBUG: Clear all files!
    NSString *publissPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [NSFileManager.defaultManager removeItemAtPath:publissPath error:NULL];
#endif

    NSAssert(PUBConfig.sharedConfig.appToken != nil, @"You need to provide an app token setup with PUBConfig.sharedConfig.appToken = @\"token\"");
    NSAssert(PUBConfig.sharedConfig.appSecret != nil, @"You need to provide an app secret setup with PUBConfig.sharedConfig.appSecret = @\"secret\"");
    
    if (PUBConfig.sharedConfig.webserviceBaseURL == nil) {
        PUBConfig.sharedConfig.webserviceBaseURL = [NSURL URLWithString:@"https://backend.publiss.com"];
    }
    
    if (PUBConfig.sharedConfig.inAppPurchaseActive == nil) {
        PUBConfig.sharedConfig.inAppPurchaseActive = NO;
    }

    if (PUBConfig.sharedConfig.pageTrackTime == nil) {
        PUBConfig.sharedConfig.pageTrackTime = @4;
    }
    
    if (PUBConfig.sharedConfig.primaryColor == nil) {
        PUBConfig.sharedConfig.primaryColor = [UIColor colorWithRed:3/255.0f green:172/255.0f blue:193/255.0f alpha:1];
    }
    
    if (licenseString != nil && ![licenseString isEqualToString:@""]) {
        PSPDFSetLicenseKey((char*)[licenseString UTF8String]);
    }
    
    // Reset data model
    [PUBDocument restoreDocuments];
    
    // Track GA
    [self setupGoogleAnalytics];
    
    // Start statistics async.
    dispatch_async(dispatch_get_main_queue(), ^{
        PUBLogVerbose(@"Statistics Key: %@", PUBStatisticsManager.sharedInstance.appID);
        [NSNotificationCenter.defaultCenter postNotificationName:PUBApplicationDidStartNotification
                                                          object:self
                                                        userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f",NSDate.date.timeIntervalSince1970],
                                                                   PUBStatisticsEventKey: PUBStatisticsEventStartKey,
                                                                   PUBStatisticsAppIDKey: PUBStatisticsManager.sharedInstance.appID}];
    });
}

#pragma mark - Google Analytics

- (void)setupGoogleAnalytics {
    if (PUBConfig.sharedConfig.googleAnalyticsTrackingCode.length > 0) {
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance.trackUncaughtExceptions = YES;
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance.dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
        //GAI.sharedInstance.logger.logLevel = kGAILogLevelVerbose;
        
        id<GAITracker> tracker = [GAI.sharedInstance trackerWithTrackingId:PUBConfig.sharedConfig.googleAnalyticsTrackingCode];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"             // Event category (required)
                                                              action:@"Start"           // Event action (required)
                                                               label:@"Start"           // Event label
                                                               value:nil] build]];      // Event value
    }
}


@end
