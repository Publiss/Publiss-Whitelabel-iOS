//
//  PUBDocumentTransition.h
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBaseTransition.h"

typedef NS_ENUM(NSInteger, PUBTargetPosition) {
    PUBTargetPositionCenter = 0,
    PUBTargetPositionLeft,
    PUBTargetPositionRight,
};

@interface PUBDocumentTransition : PUBBaseTransition

@property (nonatomic, strong) UIView *transitionSourceView;
@property (nonatomic, strong) UIImage *transitionImage;
@property (nonatomic, assign) PUBTargetPosition targetPosition;

@end
