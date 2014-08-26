//
//  UIColor+Design.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "UIColor+PUBDesign.h"

@implementation UIColor (PUBDesign)

static NSDictionary *colors;
+ (void)initialize {
    NSString *path = [NSBundle.mainBundle pathForResource:@"Design" ofType:@"plist"];
    colors = [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (UIColor *)publissPrimaryColor {
    return [self _colorWithName:@"PrimaryColor"];
}

+ (UIColor *)publissSecondaryColor {
    return [self _colorWithName:@"SecondaryColor"];
}

+ (UIColor *)publissCoverBadgeColor {
    return [self _colorWithName:@"CoverBadgeColor"];
}

+ (UIColor *)publissBlueColor {
    return [self _colorWithName:@"PublissBlue"];
}

+ (UIColor *)fontColor {
    return [self _colorWithName:@"FontColor"];
}

+ (UIColor *)menuIconColor {
    return [self _colorWithName:@"MenuIconColor"];
}

+ (UIColor *)_colorWithName:(NSString *)name {
    NSDictionary *colorDict = colors[name];

    NSNumber *red = colorDict[@"red"];
    NSNumber *green = colorDict[@"green"];
    NSNumber *blue = colorDict[@"blue"];

    return [self colorWithRed:red.floatValue / 255.0f
                        green:green.floatValue / 255.0f
                         blue:blue.floatValue / 255.0f
                        alpha:1.0f];
}


@end
