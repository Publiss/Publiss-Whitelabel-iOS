//
//  PUBBaseTransition.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBaseTransition.h"

@implementation PUBBaseTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _transitionMode == TransitionModePresent ? DURATION_PRESENT : DURATION_DISMISS;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"Needs to be overwritten.");
}

@end
