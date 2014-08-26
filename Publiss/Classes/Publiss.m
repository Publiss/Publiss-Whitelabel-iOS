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

@implementation Publiss

+ (void)setupWithLicenseKey:(NSString *)licenseString {
#if defined(PUBClearAllFilesOnAppStart) && PUBClearAllFilesOnAppStart
    // DEBUG: Clear all files!
    NSString *publissPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [NSFileManager.defaultManager removeItemAtPath:publissPath error:NULL];
#endif
    
    if (licenseString != nil && ![licenseString isEqualToString:@""]) {
        PSPDFSetLicenseKey((char*)[licenseString UTF8String]);
    }
    
    // Reset data model
    [PUBDocument restoreDocuments];
    
    // Track GA
    [Publiss loadGoogleAnalytics];
    
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

+ (void)loadGoogleAnalytics {
    if (PUBConfig.sharedConfig.GATrackingCode.length > 0) {
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance.trackUncaughtExceptions = YES;
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance.dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
        //GAI.sharedInstance.logger.logLevel = kGAILogLevelVerbose;
        
        id<GAITracker> tracker = [GAI.sharedInstance trackerWithTrackingId:[[PUBConfig sharedConfig] GATrackingCode]];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"             // Event category (required)
                                                              action:@"Start"           // Event action (required)
                                                               label:@"Start"           // Event label
                                                               value:nil] build]];      // Event value
    }
}


@end
