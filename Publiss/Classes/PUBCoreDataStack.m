//
//  PUBCoreDataStack.m
//  Publiss
//
//  Created by Daniel Griesser on 26.08.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCoreDataStack.h"

@interface PUBCoreDataStack ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation PUBCoreDataStack

+ (PUBCoreDataStack *)sharedCoreDataStack {
    static PUBCoreDataStack *sharedCoreDataStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreDataStack = [[self alloc] init];
    });
    return sharedCoreDataStack;
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


@end
