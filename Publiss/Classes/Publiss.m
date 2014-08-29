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

- (NSBundle *)bundle
{
    NSBundle *bundle;
    
    if (self.alwaysUseMainBundleForLocalization) {
        bundle = [NSBundle mainBundle];
    } else {
        bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Publiss" withExtension:@"bundle"]];
    }
    
    NSLog(@"%@", NSLocalizedStringFromTableInBundle(@"Downloading Document %@", @"PublissLocalizable", bundle, nil));
    return bundle;
}

- (void)setupWithLicenseKey:(const char *)licenseKey {
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
    
    if (PUBConfig.sharedConfig.pageTrackTime == nil) {
        PUBConfig.sharedConfig.pageTrackTime = @4;
    }
    
    if (PUBConfig.sharedConfig.primaryColor == nil) {
        PUBConfig.sharedConfig.primaryColor = [UIColor colorWithRed:3/255.0f green:172/255.0f blue:193/255.0f alpha:1];
    }
    
    if (licenseKey != nil) {
        PSPDFSetLicenseKey(licenseKey);
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

- (void)customizeLocalization {
    // Either use the block-based system.
    PUBSetLocalizationBlock(^NSString *(NSString *stringToLocalize) {
        // This will look up strings in language/PSPDFKit.strings inside resources.
        // (In PSPDFCatalog, there are no such files, this is just to demonstrate best practice)
        return NSLocalizedStringFromTable(stringToLocalize, @"PSPDFKit", nil);
        //return [NSString stringWithFormat:@"_____%@_____", stringToLocalize];
    });
    
    // Or override via dictionary.
    // See PSPDFKit.bundle/en.lproj/PSPDFKit.strings for all available strings.
    PUBSetLocalizationDictionary(@{@"en" : @{@"%d of %d" : @"Page %d of %d",
                                               @"%d-%d of %d" : @"Pages %d-%d of %d"}});
}

@end

#pragma mark Localization

static __strong NSString *(^_localizationBlock)(NSString *stringToLocalize) = nil;
static __strong NSDictionary *_localizationDict = nil;

NSBundle *PublissBundle(void) {
    static __strong NSBundle *publiss_bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publiss_bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"Publiss.bundle"]];

        if (!publiss_bundle) {
            PUBLogError(@"Error! Publiss.bundle not found.");
        }
    });
    
    return publiss_bundle;
}

static NSString *PUBPreferredLocale(void) {
    static NSString *locale = nil;
    if (!locale) {
        locale = NSLocale.preferredLanguages.firstObject;
        if (!locale) {
            PUBLogWarning(@"No preferred language? `[NSLocale preferredLanguages]` returned nil. Defaulting to english.");
            locale = @"en";
        }
    }
    return locale;
}

void PUBSetLocalizationBlock(NSString *(^localizationBlock)(NSString *stringToLocalize)) {
    _localizationBlock = [localizationBlock copy];
}

void PUBSetLocalizationDictionary(NSDictionary *localizationDict) {
    @synchronized(UIApplication.sharedApplication) {
        if (localizationDict != _localizationDict) {
            _localizationDict = [localizationDict copy];
        }
    }
    PUBLogVerbose(@"new localization dictionary set. locale: %@; dict: %@", PUBPreferredLocale(), localizationDict);
}

NSString *PUBLocalize(NSString *stringToken) {
    NSCParameterAssert(stringToken);
    
    // Call the block. (#1 Priority)
    NSString *localization = _localizationBlock ? _localizationBlock(stringToken) : nil;
    
    // Load language from bundle.
    if (!localization) {
        localization = [PublissBundle() localizedStringForKey:stringToken value:@"" table:@"PublissLocalizable"] ?: stringToken;

        // Try loading from the global translation dict.
        NSString *replLocale = nil;
        if (_localizationDict) {
            NSString *language = PUBPreferredLocale();
            NSDictionary *languageDict = _localizationDict[language];
            replLocale = languageDict[stringToken];
            if (!replLocale && !languageDict && ![language isEqualToString:@"en"]) {
                replLocale = _localizationDict[@"en"][stringToken];
            }
            if (replLocale) localization = replLocale;
        }
    }
    
    return localization;
}

