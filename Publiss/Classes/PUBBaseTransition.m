//
//  PUBBaseTransition.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBaseTransition.h"
#import "PUBConstants.h"

@implementation PUBBaseTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _transitionMode == TransitionModePresent ? DURATION_PRESENT : DURATION_DISMISS;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"Needs to be overwritten.");
}

//TODO: Move in UINavigationControllerCategory
- (void)hideNavigationBarOfController:(UIViewController *)controller withDuration:(CGFloat)duration {
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [controller.navigationController.navigationBar.layer addAnimation:transition forKey:kCATransition];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (self.animationEndedBlock) {
        self.animationEndedBlock(transitionCompleted, _transitionMode);
    }
}

@end
