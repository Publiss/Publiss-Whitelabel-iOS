//
//  PUBBadgeView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBadgeView.h"

@implementation PUBBadgeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawBackground];
    [self drawIcon];
}

- (void)drawBackground {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path closePath];
    [self.fillColor setFill];
    [path fill];
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
}

- (void)drawIcon {
    if (self.icon == nil) {
        return;
    }

    CGRect iconRect = CGRectMake(self.frame.size.width - self.icon.size.width + self.iconOffset.width,
                                 self.iconOffset.height, self.icon.size.width, self.icon.size.height);

    [self.icon drawInRect:iconRect];
}

@end
