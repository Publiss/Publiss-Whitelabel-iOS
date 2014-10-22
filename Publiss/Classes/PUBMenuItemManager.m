//
//  PUBMenuItemManager.m
//  Publiss
//
//  Created by Daniel Griesser on 22.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuItemManager.h"

@interface PUBMenuItemManager()

@property (nonatomic, strong) NSMutableArray *menuItemsStore;

@end

@implementation PUBMenuItemManager

+ (PUBMenuItemManager *)sharedInstance {
    static PUBMenuItemManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = PUBMenuItemManager.alloc.init;
        _sharedInstance.menuItemsStore = NSMutableArray.array;
    });
    return _sharedInstance;
}

- (void)addMenuItem:(PUBMenuItem *)item {
    [self.menuItemsStore addObject:item];
}

- (void)removeMenuItem:(PUBMenuItem *)item {
    [self.menuItemsStore removeObject:item];
}

- (void)removeMenuItemAtIndex:(NSUInteger)index {
    [self.menuItemsStore removeObjectAtIndex:index];
}

- (NSArray *)items {
    return self.menuItemsStore;
}

@end
