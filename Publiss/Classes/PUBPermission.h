//
//  PUBPermission.h
//  Publiss
//
//  Created by Daniel Griesser on 30.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PUBDocument;

@interface PUBPermission : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PUBDocument *document;

@end
