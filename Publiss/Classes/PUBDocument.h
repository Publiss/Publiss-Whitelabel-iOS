//
//  PUBDocument.h
//  Publiss
//
//  Created by Denis Andrasec on 12.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PUBLanguage;

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
@property (nonatomic) BOOL showInKiosk;
@property (nonatomic) uint16_t priority;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic) uint64_t publishedID;
@property (nonatomic) uint64_t size;
@property (nonatomic, retain) NSData * sizesData;
@property (nonatomic) uint16_t state;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *featuredUpdatedAt;

@property (nonatomic, retain) PUBLanguage *language;

@end
