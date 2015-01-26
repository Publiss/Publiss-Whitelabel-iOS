//
//  PUBWebViewController.m
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBWebViewController.h"
#import "PUBConfig.h"

@implementation PUBWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return PUBConfig.sharedConfig.statusBarStyle;
}

@end
