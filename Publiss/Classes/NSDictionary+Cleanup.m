//
//  NSDictionary+Cleanup.m
//  Publiss
//
//  Created by Denis Andrasec on 27.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "NSDictionary+Cleanup.h"

@implementation NSDictionary (Cleanup)

- (NSDictionary *)dictionaryWithoutEmptyStringsForMissingValues {
    NSMutableDictionary *mutablemeta = [NSMutableDictionary dictionaryWithDictionary:self];
    NSMutableDictionary *replacedmeta = [mutablemeta mutableCopy];
    for (NSString* key in mutablemeta) {
        if ([mutablemeta objectForKey:key] == nil || [mutablemeta objectForKey:key] == [NSNull null]) {
            [replacedmeta setObject:@"" forKey:key];
        }
    }
    
    return replacedmeta.copy;
}

@end
