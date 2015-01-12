//
//  PUBLanguage+Helper.h
//  Publiss
//
//  Created by Denis Andrasec on 12.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBLanguage.h"

@interface PUBLanguage (Helper)

+ (PUBLanguage *)createOrUpdateWithDocument:(PUBDocument *)document
                              andDictionary:(NSDictionary *)dictionary;

+ (NSArray *)fetchAllUniqueLinkedTags;

@end
