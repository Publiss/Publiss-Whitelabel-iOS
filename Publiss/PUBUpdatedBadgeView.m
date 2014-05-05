//
//  PUBUpdatedView.m
//  Publiss
//
//  Created by Denis Andrasec on 30.04.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUpdatedBadgeView.h"
#import "UIColor+Design.h"

@interface PUBUpdatedBadgeView()

@property (nonatomic, strong) UILabel *updatedLabel;

@end

@implementation PUBUpdatedBadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.updatedLabel.frame = CGRectMake(0, 0, 44, 12);
    self.updatedLabel.center = CGPointMake(self.bounds.size.width / 2 + 6,
                                           self.bounds.size.height / 2 - 6);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Banner
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor publissPrimaryColor] CGColor]));
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height/2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2, 0)];
    [path closePath];
    
    [path fill];
}

- (UILabel *)updatedLabel
{
    if (!_updatedLabel) {
        _updatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 12)];
        _updatedLabel.text = @"UPDATE";
        _updatedLabel.textAlignment = NSTextAlignmentCenter;
        _updatedLabel.font = [UIFont systemFontOfSize:10];
        _updatedLabel.textColor = [UIColor whiteColor];
        _updatedLabel.transform = CGAffineTransformMakeRotation((45 * M_PI) / 180.0);
        [self addSubview:_updatedLabel];
    }
    return _updatedLabel;
}

@end
