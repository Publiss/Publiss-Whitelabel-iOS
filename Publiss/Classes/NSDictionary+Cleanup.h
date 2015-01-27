//
//  NSDictionary+Cleanup.h
//  Publiss
//
//  Created by Denis Andrasec on 27.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Cleanup)

/// Replace all NSNull and nil values with @""
- (NSDictionary *)dictionaryWithoutEmptyStringsForMissingValues;

@end
