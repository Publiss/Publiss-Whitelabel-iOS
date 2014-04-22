//
//  PUBCustomGalleryViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBGalleryViewController.h"

@interface PUBGalleryViewController ()

@end

@implementation PUBGalleryViewController


- (id)initWithLinkAnnotation:(PSPDFLinkAnnotation *)annotation {
    if ((self = [super initWithLinkAnnotation:annotation])) {
        self.backgroundColor = [UIColor colorWithWhite:.5f alpha:.2f];
        self.fullscreenBackgroundColor = [UIColor colorWithWhite:.0f alpha:.9f];
        self.blurBackground = NO;
    }
    return self;
}

@end
