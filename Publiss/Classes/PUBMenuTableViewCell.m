//
//  PUBMenuTableViewCell.m
//  Publiss
//
//  Created by Daniel Griesser on 22.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuTableViewCell.h"
#import "PUBConfig.h"
#import "UIColor+PUBDesign.h"
#import "UIImage+PUBTinting.h"

@implementation PUBMenuTableViewCell

- (void)awakeFromNib {
    self.tintColor = PUBConfig.sharedConfig.secondaryColor;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_font) {
        self.titleLabel.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    if (_textColor) {
        self.titleLabel.textColor = _textColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        UIColor *color = !self.highlightedTextColor ? PUBConfig.sharedConfig.primaryColor : self.highlightedTextColor;
        self.titleLabel.textColor = color;
        self.icon.image = [self.icon.image imageTintedWithColor:color fraction:0.f];
    } else {
        UIColor *color = !self.textColor ? self.tintColor : self.textColor;
        self.titleLabel.textColor = color;
        self.icon.image = [self.icon.image imageTintedWithColor:color fraction:0.f];
    }
}

@end
