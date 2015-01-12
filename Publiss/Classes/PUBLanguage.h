//
//  PUBLanguage.h
//  Publiss
//
//  Created by Denis Andrasec on 12.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PUBDocument;

@interface PUBLanguage : NSManagedObject

@property (nonatomic, retain) NSString * linkedTag;
@property (nonatomic, retain) NSString * languageTag;
@property (nonatomic, retain) NSString * localizedTitle;
@property (nonatomic, retain) PUBDocument *document;

@end
