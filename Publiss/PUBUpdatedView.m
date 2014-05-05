//
//  PUBUpdatedView.m
//  Publiss
//
//  Created by Denis Andrasec on 30.04.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUpdatedView.h"
#import "UIColor+Design.h"

@implementation PUBUpdatedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor publissPrimaryColor] CGColor]));
    CGContextFillPath(ctx);
}


@end
