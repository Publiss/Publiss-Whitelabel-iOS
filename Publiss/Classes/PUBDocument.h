//
//  PUBDocument.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PUBDocument : NSManagedObject

@property (nonatomic, retain) NSData * dimensionsData;
@property (nonatomic) uint64_t downloadedSize;
@property (nonatomic) float downloadProgress;
@property (nonatomic, retain) NSString * fileDescription;
@property (nonatomic) uint64_t fileSize;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic) uint16_t pageCount;
@property (nonatomic) BOOL paid;
@property (nonatomic) BOOL featured;
@property (nonatomic) uint16_t priority;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic) uint64_t publishedID;
@property (nonatomic) uint64_t size;
@property (nonatomic, retain) NSData * sizesData;
@property (nonatomic) uint16_t state;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate *updatedAt;

@end
