//
//  PUBCrossfadeTransition.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBFadeTransition.h"
#import "PUBDimmView.h"

@interface PUBFadeTransition ()

@property (nonatomic, strong) PUBDimmView *dimmView;

@end

@implementation PUBFadeTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    if (self.transitionMode == TransitionModePresent) {
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.dimmView = [[PUBDimmView alloc] initWithFrame:container.frame];
            self.dimmView.alpha = 0.0;
            [container addSubview:self.dimmView];
        }
        
        toView.alpha = 0.0f;
        toView.frame = [self endFrameForController:toVC inContainer:container];
        [container addSubview:toView];
        
        if (self.shouldHideStatusBar) {
            [self hideNavigationBarOfController:toVC withDuration:DURATION_PRESENT];
        }
        
        [UIView animateWithDuration:DURATION_PRESENT
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toView.alpha = 1.0;
                             self.dimmView.alpha = DIMM_VIEW_ALPHA;
                         }
                         completion:^(BOOL finished) {
                             
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        fromView.alpha = 1.0;
        self.dimmView.alpha = DIMM_VIEW_ALPHA;
        
        if (toView.superview == nil) {
            [container insertSubview:toView belowSubview:fromView];
        }
        
        [UIView animateWithDuration:DURATION_DISMISS
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             fromView.alpha = 0.0;
                             self.dimmView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.dimmView removeFromSuperview];
                             self.dimmView = nil;
                             
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
