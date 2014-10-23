//
//  PUBImageReusableView.m
//  Publiss
//
//  Created by Denis Andrasec on 14.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBImageReusableView.h"

@implementation PUBImageReusableView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = YES;
        _imageView.image = [UIImage imageNamed:@"KioskShelveBackground"];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
}

+ (NSString *)kind {
    return @"PUBImageReusableViewKind";
}

@end
