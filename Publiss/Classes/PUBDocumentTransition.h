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

@protocol PUBDocumentTransitionDataSource;

@interface PUBDocumentTransition : PUBBaseTransition

@property (nonatomic, assign) id<PUBDocumentTransitionDataSource> dataSource;


@property (nonatomic, copy) UIImage *transitionImage;
@property (nonatomic, assign) PUBTargetPosition targetPosition;

+ (PUBTargetPosition)targetPositionForPageIndex:(NSInteger)pageIndex
                             isDoubleModeActive:(BOOL)doubleModeActive;

@end

@protocol PUBDocumentTransitionDataSource <NSObject>


@required
- (UIView *)currentTransitionSourceView;

@optional
- (UIImage *)currentTransitionImage;

@end
