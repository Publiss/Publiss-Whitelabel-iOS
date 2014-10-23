//
//  PUBDimmView.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDimmView.h"

@implementation PUBDimmView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.tag = DIMM_VIEW_TAG;
    }
    return self;
}

@end
