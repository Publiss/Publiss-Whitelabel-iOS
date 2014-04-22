//
//  PUBAppDelegate.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBAppDelegate.h"
#import "PUBDocument+Helper.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "PUBStatisticsManager.h"
#import "UIColor+Design.h"

@interface PUBAppDelegate ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation PUBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if defined(PUBClearAllFilesOnAppStart) && PUBClearAllFilesOnAppStart
    // DEBUG: Clear all files!
    NSString *publissPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [NSFileManager.defaultManager removeItemAtPath:publissPath error:NULL];
#endif

    //PSPDFSetLicenseKey("");

    // Apply global tintColor to icons, fonts in navigationbar etc
    self.window.tintColor = UIColor.fontColor;

    // Reset data model
    [PUBDocument restoreDocuments];

    // Start statistics async.
    dispatch_async(dispatch_get_main_queue(), ^{
        PUBLogVerbose(@"Statistics Key: %@", PUBStatisticsManager.sharedInstance.appID);
        [NSNotificationCenter.defaultCenter postNotificationName:PUBApplicationDidStartNotification
                                                          object:self
                                                        userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f",NSDate.date.timeIntervalSince1970],
                                                                   PUBStatisticsEventKey: PUBStatisticsEventStartKey,
                                                                   PUBStatisticsAppIDKey: PUBStatisticsManager.sharedInstance.appID}];
    });

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [NSNotificationCenter.defaultCenter postNotificationName:PUBApplicationWillResignActiveNotification object:nil];
}

- (void)saveContext {
    PUBLogVerbose(@"%@: Saving context", self.class);
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            PUBLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Core Data stack

static NSString *const kPublissStore = @"Publiss.sqlite";

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the
// application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Publiss" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

   NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:kPublissStore];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};

    NSError *error = nil;
    // Make sure that the parent directory exists.
    [NSFileManager.defaultManager createDirectoryAtURL:storeURL.URLByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:NULL];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        if (error) {
            
            _persistentStoreCoordinator = nil;
            PUBLogError(@"Error while creating database: %@", error);
            [self deleteExisitingStore:storeURL];
            return [self persistentStoreCoordinator];
        }
        PUBLogVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }

    return _persistentStoreCoordinator;
}

- (void)deleteExisitingStore:(NSURL *)storeURL {
    [NSFileManager.defaultManager removeItemAtURL:storeURL error:nil];
    self.managedObjectContext = nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

}

#pragma mark - Google Analytics

- (void)loadGoogleAnalytics {
    /*
     Note: When you obtain a tracker for a given tracking ID, the tracker instance is persisted in the library. When you call trackerWithTrackingId: with the same tracking ID later, the same tracker instance will be returned. Also, the Google Analytics SDK exposes a default tracker instance that gets set to the first tracker instance created. It can be accessed by:
     */
    if ([[PUBConfig sharedConfig] GATrackingCode]) {
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance.trackUncaughtExceptions = YES;
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance.dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
        //GAI.sharedInstance.logger.logLevel = kGAILogLevelVerbose;

        id<GAITracker> tracker = [GAI.sharedInstance trackerWithTrackingId:[[PUBConfig sharedConfig] GATrackingCode]];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Whitelabel App" // Event category (required)
                                                              action:@"Start"          // Event action (required)
                                                               label:@"Start"          // Event label
                                                               value:nil] build]];     // Event value
    }
}

@end
