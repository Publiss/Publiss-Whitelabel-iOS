//
//  UIColor+Design.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "UIColor+PUBDesign.h"
#import <PublissCore.h>
#import "PUBConfig.h"

@implementation UIColor (PUBDesign)

+ (UIColor *)publissPrimaryColor {
    return PUBConfig.sharedConfig.primaryColor;
}

+ (UIColor *)publissSecondaryColor {
    return PUBConfig.sharedConfig.secondaryColor;
}

+ (UIColor *)kioskBackgroundColor {
    return PUBConfig.sharedConfig.kioskBackgroundColor;
}

@end
