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
    
    UIImageView *blendOverView = [[UIImageView alloc] initWithImage:self.sourceImage];
    blendOverView.contentMode = UIViewContentModeScaleAspectFill;
    blendOverView.clipsToBounds = YES;
    
    
    
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
        
        UIView *transitionImageViewTarget = [toView snapshotViewAfterScreenUpdates:YES];
        if (PUBIsiPad()) {
            transitionImageViewTarget = [[UIImageView alloc] initWithFrame:toView.frame];
            transitionImageViewTarget.backgroundColor = [UIColor whiteColor];
            ((UIImageView *)transitionImageViewTarget).image = [self screenshot:toView];
        }
        
        transitionImageViewTarget.frame = startRect;
        [container addSubview:transitionImageViewTarget];
        
        blendOverView.frame = startRect;
        [container addSubview:blendOverView];
                
        toView.hidden = YES;
        
        self.transitionSourceView.hidden = YES;
        self.transitionSourceView.superview.hidden = YES;
        
        [UIView animateWithDuration:DURATION_PRESENT
                              delay:0.f
             usingSpringWithDamping:PUBIsiPad() ? .8f : 2.5f
              initialSpringVelocity:17.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             blendOverView.alpha = 0;
                             blendOverView.frame = endRect;
                             
                             toView.frame = endRect;
                             transitionImageViewTarget.frame = endRect;
                             dimView.alpha = DIMM_VIEW_ALPHA;
                         }
                         completion:^(BOOL finished) {
                             toView.hidden = NO;
                             [blendOverView removeFromSuperview];
                             [transitionImageViewTarget removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        fromView.alpha = 1.0;
        
        UIView *dimView = [container viewWithTag:DIMM_VIEW_TAG];
        dimView.alpha = DIMM_VIEW_ALPHA;
        
        startRect = [self endFrameForController:fromVC inContainer:container];
        endRect = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:container];
        
        UIView *transitionImageViewTarget = [fromView snapshotViewAfterScreenUpdates:YES];
        transitionImageViewTarget.frame = startRect;
        [container addSubview:transitionImageViewTarget];
        
        blendOverView.frame = startRect;
        blendOverView.alpha = 0;
        [container addSubview:blendOverView];
        
        [UIView animateKeyframesWithDuration:DURATION_DISMISS
                                       delay:0.f
                                     options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             blendOverView.alpha = 1;
                             blendOverView.frame = endRect;
                             
                             fromView.frame = endRect;
                             transitionImageViewTarget.frame = endRect;
                             dimView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [transitionImageViewTarget removeFromSuperview];
                             [blendOverView removeFromSuperview];
                             [dimView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                             
                             self.transitionSourceView.hidden = NO;
                             self.transitionSourceView.superview.hidden = NO;
                         }];
    }
}

- (UIImage *)screenshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [view drawViewHierarchyInRect:CGRectMake(0, -20, view.bounds.size.width, view.bounds.size.height) afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
