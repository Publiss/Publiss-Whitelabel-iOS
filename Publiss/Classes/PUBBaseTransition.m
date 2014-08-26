//
//  PUBBaseTransition.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBaseTransition.h"

const CGFloat DURATION_PRESENT = 3.0f;
const CGFloat DURATION_DISMISS = 3.0f;

@implementation PUBBaseTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _transitionMode == TransitionModePresent ? DURATION_PRESENT : DURATION_DISMISS;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"needs to be overwritten");
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    _transitionMode = TransitionModePresent;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _transitionMode = TransitionModeDismiss;
    return self;
}

@end
