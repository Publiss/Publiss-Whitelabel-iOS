//
//  PUBAppearence.m
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBAppearence.h"

@implementation PUBAppearence

+ (PUBAppearence *)sharedAppearence {
    static dispatch_once_t _onceToken;
    static PUBAppearence *_sharedAppearence = nil;
    dispatch_once(&_onceToken, ^{
        _sharedAppearence = [PUBAppearence new];
        _sharedAppearence.statusBarStyle = UIStatusBarStyleLightContent;
        [[UIApplication sharedApplication] setStatusBarStyle:_sharedAppearence.statusBarStyle];
    });
    return _sharedAppearence;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
}

@end
