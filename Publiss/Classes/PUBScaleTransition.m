//
//  PUBScaleTransition.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBScaleTransition.h"
#import "PUBConstants.h"
#import "PUBDimmView.h"

@interface PUBScaleTransition ()

@property (strong, nonatomic) UIImageView *magazineImageView;

@end

@implementation PUBScaleTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    CGRect startRect;
    CGRect endRect;
    
    UIView *transitionImageView;
    
    if (self.transitionMode == TransitionModePresent) {
        
        UIView *dimView;
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            dimView = [[PUBDimmView alloc] initWithFrame:container.frame];
            dimView.alpha = 0.0;
            [container addSubview:dimView];
        }
        
        [container addSubview:toView];
        
        startRect = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:container];
        endRect = [self endFrameForController:toVC inContainer:container];
        
        transitionImageView = [toView snapshotViewAfterScreenUpdates:YES];
        transitionImageView.frame = startRect;
        [container addSubview:transitionImageView];
        
        toView.hidden = YES;
        
        self.transitionSourceView.hidden = YES;
        self.transitionSourceView.superview.hidden = YES;
        
        [UIView animateWithDuration:DURATION_PRESENT
                              delay:0.f
             usingSpringWithDamping:PUBIsiPad() ? .8f : 2.5f
              initialSpringVelocity:17.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toView.frame = endRect;
                             transitionImageView.frame = endRect;
                             dimView.alpha = DIMM_VIEW_ALPHA;
                         }
                         completion:^(BOOL finished) {
                             toView.hidden = NO;
                             [transitionImageView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        fromView.alpha = 1.0;
        
        UIView *dimView = [container viewWithTag:DIMM_VIEW_TAG];
        dimView.alpha = DIMM_VIEW_ALPHA;
        
        startRect = [self endFrameForController:fromVC inContainer:container];
        endRect = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:container];
        
        transitionImageView = [fromView snapshotViewAfterScreenUpdates:YES];
        transitionImageView.frame = startRect;
        [container addSubview:transitionImageView];
        
        [UIView animateKeyframesWithDuration:DURATION_DISMISS
                                       delay:0.f
                                     options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                         animations:^{
                             fromView.frame = endRect;
                             transitionImageView.frame = endRect;
                             dimView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [transitionImageView removeFromSuperview];
                             [dimView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                             self.transitionSourceView.hidden = NO;
                             self.transitionSourceView.superview.hidden = NO;
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
