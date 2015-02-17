//
//  PUBFreeTextAccessoryView.m
//  Publiss
//
//  Created by Daniel Griesser on 17.02.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBFreeTextAccessoryView.h"

@interface PUBFreeTextAccessoryView()

@property (nonatomic, strong) PSPDFToolbarButton *fontNameButton;

@end


@implementation PUBFreeTextAccessoryView

// TODO workaround for crash
- (PSPDFToolbarButton *)fontNameButton {
    if (!_fontNameButton) {
        _fontNameButton = [[PSPDFToolbarButton alloc] init];
        _fontNameButton.flexible = YES;
        _fontNameButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
        _fontNameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        [_fontNameButton addTarget:self action:@selector(fontNamePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fontNameButton;
}

@end
