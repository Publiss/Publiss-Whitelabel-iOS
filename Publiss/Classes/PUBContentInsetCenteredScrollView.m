//
//  PSTContentInsetCenteredScrollView.m
//  PUBCenteredScrollView
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBContentInsetCenteredScrollView.h"

@implementation PUBContentInsetCenteredScrollView

- (void)centerContent {
    self.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView {
    [self centerContent];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self centerContent];
}

@end
