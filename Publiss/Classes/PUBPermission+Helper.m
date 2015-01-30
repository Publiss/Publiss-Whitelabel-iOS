//
//  PUBPermission+Helper.m
//  Publiss
//
//  Created by Daniel Griesser on 30.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBPermission+Helper.h"
#import "PUBCoreDataStack.h"
#import "PUBConstants.h"

@implementation PUBPermission (Helper)

+ (PUBPermission *)createEntity {
    PUBPermission *newEntity = [NSEntityDescription insertNewObjectForEntityForName:@"PUBPermission"
                                                             inManagedObjectContext:PUBCoreDataStack.sharedCoreDataStack.managedObjectContext];
    return newEntity;
}

@end
