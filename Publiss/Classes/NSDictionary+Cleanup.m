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
    const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in self) {
        const id object = [self objectForKey: key];
        if (object == nul) {
            [replaced setObject:blank forKey:key];
        }
        else if ([object isKindOfClass: [NSDictionary class]]) {
            [replaced setObject: [(NSDictionary *)object dictionaryWithoutEmptyStringsForMissingValues] forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:replaced.copy];
}

@end
