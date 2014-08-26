//
//  UIImage+Tinting.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "UIImage+PUBTinting.h"

@implementation UIImage (PUBTinting)

- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction {
    if (color) {
        CGRect rect = (CGRect){CGPointZero, self.size};
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
        [color set];
        UIRectFill(rect);
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.f];
        
        if (fraction > 0.0) {
            [self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Preserve accessibility label if set.
        if (self.accessibilityLabel) image.accessibilityLabel = self.accessibilityLabel;
        
        // Since we manually tint here, don't auto-tint.
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        return image;
    }
    return self;
}

@end
