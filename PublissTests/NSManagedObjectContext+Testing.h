//
//  NSManagedObjectContext+Testing.h
//  Publiss
//
//  Created by Denis Andrasec on 13.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Testing)

+ (instancetype)testing_inMemoryContext:(NSManagedObjectContextConcurrencyType)concurrencyType
                                  error:(NSError **)error;

@end
