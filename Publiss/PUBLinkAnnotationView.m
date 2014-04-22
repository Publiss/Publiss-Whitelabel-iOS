//
//  CustomLinkAnnotationView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBLinkAnnotationView.h"
#import "UIColor+Design.h"

@implementation PUBLinkAnnotationView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.borderColor = [UIColor publissPrimaryColor];
        self.strokeWidth = 2.0f;
        self.hideSmallLinks = NO;
    }
    return self;
}

@end
