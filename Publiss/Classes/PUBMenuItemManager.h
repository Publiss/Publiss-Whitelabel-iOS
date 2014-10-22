//
//  PUBMenuItemManager.h
//  Publiss
//
//  Created by Daniel Griesser on 22.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PUBMenuItem;

@interface PUBMenuItemManager : NSObject

+ (PUBMenuItemManager *)sharedInstance;

@property (nonatomic, readonly, strong) NSArray *items;

- (void)addMenuItem:(PUBMenuItem *)item;
- (void)removeMenuItem:(PUBMenuItem *)item;
- (void)removeMenuItemAtIndex:(NSUInteger)index;

@end
