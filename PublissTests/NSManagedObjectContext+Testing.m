//
//  NSManagedObjectContext+Testing.m
//  Publiss
//
//  Created by Denis Andrasec on 13.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "NSManagedObjectContext+Testing.h"

@implementation NSManagedObjectContext (Testing)

+ (instancetype)testing_inMemoryContext:(NSManagedObjectContextConcurrencyType)concurrencyType error:(NSError **)error
{
    // ObjectModel from any models in app bundle
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Coordinator with in-mem store type
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:error];
    
    // Context with private queue (for example)
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    context.persistentStoreCoordinator = coordinator;
    
    return context;
}

@end
