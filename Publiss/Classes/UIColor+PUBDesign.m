//
//  UIColor+Design.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "UIColor+PUBDesign.h"
#import <PublissCore.h>

@implementation UIColor (PUBDesign)

+ (UIColor *)publissPrimaryColor {
    return PUBConfig.sharedConfig.primaryColor;
}

@end
