//
//  PUBAppearence.h
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBAppearence : NSObject

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

+ (PUBAppearence *)sharedAppearence;

@end
