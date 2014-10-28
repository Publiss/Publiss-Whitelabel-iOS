//
//  PUBMenuTableViewCell.m
//  Publiss
//
//  Created by Daniel Griesser on 22.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuTableViewCell.h"
#import "PUBConfig.h"
#import "UIImage+PUBTinting.h"

@implementation PUBMenuTableViewCell

- (void)awakeFromNib {
    self.tintColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.titleLabel.textColor = PUBConfig.sharedConfig.primaryColor;
        self.icon.image = [self.icon.image imageTintedWithColor:PUBConfig.sharedConfig.primaryColor fraction:0.f];
    } else {
        self.titleLabel.textColor = self.tintColor;
        self.icon.image = [self.icon.image imageTintedWithColor:self.tintColor fraction:0.f];
    }
}

@end
