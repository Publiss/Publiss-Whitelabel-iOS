//
//  PUBHeaderReusableView.m
//  Publiss
//
//  Created by Denis Andrasec on 15.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBHeaderReusableView.h"

@interface PUBHeaderReusableView()

@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation PUBHeaderReusableView

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
    self.imageView.image = [UIImage imageNamed:@"HeaderBackground"];
    [self addGestureRecognizer:self.singleTapRecognizer];
    [self addGestureRecognizer:self.longPressRecognizer];
}

- (UITapGestureRecognizer *)singleTapRecognizer {
    if (!_singleTapRecognizer) {
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
    }
    return _singleTapRecognizer;
}

- (UILongPressGestureRecognizer *)longPressRecognizer {
    if (!_longPressRecognizer) {
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction)];
    }
    return _longPressRecognizer;
}

- (void)singleTapAction {
    if (self.singleTapBlock) {
        self.singleTapBlock(0);
    }
}

- (void)longPressAction {
    if (self.longPressBlock) {
        self.longPressBlock(0);
    }
}

@end
