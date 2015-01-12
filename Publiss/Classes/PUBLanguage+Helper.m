//
//  PUBLanguage+Helper.m
//  Publiss
//
//  Created by Denis Andrasec on 12.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBLanguage+Helper.h"
#import "PUBCoreDataStack.h"
#import "PUBConstants.h"
#import "PUBDocument+Helper.h"

@implementation PUBLanguage (Helper)

+ (PUBLanguage *)createEntity {
    PUBLanguage *newEntity = [NSEntityDescription insertNewObjectForEntityForName:@"PUBLanguage"
                                                           inManagedObjectContext:PUBCoreDataStack.sharedCoreDataStack.managedObjectContext];
    return newEntity;
}

+ (PUBLanguage *)createOrUpdateWithDocument:(PUBDocument *)document
                              andDictionary:(NSDictionary *)dictionary {

    if (![dictionary isKindOfClass:NSDictionary.class] || dictionary.count == 0) {
        PUBLogWarning(@"Dictionary is empty.");
        return nil;
    }
    
    PUBLanguage *language = document.language;
    if (nil == language) {
        language = [PUBLanguage createEntity];
        language.document = document;
    }
    
    NSString *localizedTitle = PUBSafeCast(dictionary[@"title"], NSString.class);
    NSString *languageTag = PUBSafeCast(dictionary[@"lang"], NSString.class);
    NSString *linkedTag = PUBSafeCast(dictionary[@"linked"], NSString.class);
    
    if (nil == language.localizedTitle || ![language.localizedTitle isEqualToString:localizedTitle]) {
        language.localizedTitle = localizedTitle;
    }
    
    if (nil == language.languageTag || ![language.languageTag isEqualToString:languageTag]) {
        language.languageTag = languageTag;
    }
    
    if (nil == language.linkedTag || ![language.linkedTag isEqualToString:linkedTag]) {
        language.linkedTag = linkedTag;
    }
    
    return language;
}

@end
