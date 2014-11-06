//
//  PUBFooterReusableView.m
//  Publiss
//
//  Created by Daniel Griesser on 06.11.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBFooterReusableView.h"

@implementation PUBFooterReusableView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"KioskShelveBackground"]] colorWithAlphaComponent:1.0f];
}

@end
