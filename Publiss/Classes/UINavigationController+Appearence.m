//
//  UINavigationController+Appearence.m
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "UINavigationController+Appearence.h"

@implementation UINavigationController (Appearence)

- (UIStatusBarStyle) preferredStatusBarStyle{
    return [[self topViewController] preferredStatusBarStyle];
}

@end
