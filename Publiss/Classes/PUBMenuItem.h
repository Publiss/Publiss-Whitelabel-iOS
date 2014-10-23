//
//  PUBMenuItem.h
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBMenuItem : NSObject

@property (nonatomic, copy) void(^actionBlock)();
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end
