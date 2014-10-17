//
//  PUBCrossfadeTransition.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCrossfadeTransition.h"
#import "PUBDimmView.h"

const CGFloat DURATION_PRESENT = 0.25f;
const CGFloat DURATION_DISMISS = 0.25f;

@implementation PUBCrossfadeTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    if (self.transitionMode == TransitionModePresent) {
        UIView *dimView;
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            dimView = [[PUBDimmView alloc] initWithFrame:container.frame];
            dimView.alpha = 0.0;
            
            [container addSubview:dimView];
        }
        
        [container addSubview:toView];
        
        toView.alpha = 0.0f;
        toView.frame = [self endFrameForController:toVC inContainer:container];
        
        [UIView animateWithDuration:DURATION_PRESENT
                              delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             toView.alpha = 1.0;
                             dimView.alpha = DIMM_VIEW_ALPHA;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        fromView.alpha = 1.0;
        
        UIView *dimView = [container viewWithTag:DIMM_VIEW_TAG];
        dimView.alpha = DIMM_VIEW_ALPHA;
        
        [UIView animateWithDuration:DURATION_DISMISS
                              delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             fromView.alpha = 0.0;
                             dimView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [dimView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (CGRect)endFrameForController:(UIViewController *)controller inContainer:(UIView *)container {
    CGFloat width = controller.view.frame.size.width;
    CGFloat height = controller.view.frame.size.height;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGRectMake(CGRectGetMidX(container.bounds) - width / 2.0f,
                          CGRectGetMidY(container.bounds) - height / 2.0f, width, height);
    }
    else {
        return controller.view.frame;
    }
}

@end
