//
//  PUBDocument.h
//  Publiss
//
//  Created by Daniel Griesser on 30.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PUBLanguage, PUBPermission;

@interface PUBDocument : NSManagedObject

@property (nonatomic, retain) NSData * dimensionsData;
@property (nonatomic) int64_t downloadedSize;
@property (nonatomic) float downloadProgress;
@property (nonatomic) BOOL featured;
@property (nonatomic, retain) NSString * fileDescription;
@property (nonatomic) int64_t fileSize;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic) int16_t pageCount;
@property (nonatomic) BOOL paid;
@property (nonatomic) int16_t priority;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic) int64_t publishedID;
@property (nonatomic) BOOL showInKiosk;
@property (nonatomic) int64_t size;
@property (nonatomic, retain) NSData * sizesData;
@property (nonatomic) int16_t state;
@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *featuredUpdatedAt;

@property (nonatomic, retain) PUBLanguage *language;
@property (nonatomic, retain) NSSet *permissions;
@end

@interface PUBDocument (CoreDataGeneratedAccessors)

- (void)addPermissionsObject:(PUBPermission *)value;
- (void)removePermissionsObject:(PUBPermission *)value;
- (void)addPermissions:(NSSet *)values;
- (void)removePermissions:(NSSet *)values;

@end
