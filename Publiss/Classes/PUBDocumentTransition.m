//
//  PUBDocumentTransition.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocumentTransition.h"
#import "PUBDimmView.h"

const CGFloat TRANSITION_DURATION = .45f;

@implementation PUBDocumentTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    CGRect startFrame;
    CGRect endFrame;
    
    UIImageView *documentImageView = [[UIImageView alloc] initWithImage:self.transitionImage];
    
    PUBDimmView *dimView = [[PUBDimmView alloc] initWithFrame:container.frame];
    
    if (self.transitionMode == TransitionModePresent) {
        toView.hidden = YES;
        self.transitionSourceView.hidden = YES;
        
        [container addSubview:toView];
        
        startFrame = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:container];
        endFrame = [self transitionTargetFrom:self.transitionSourceView to:toView];
        
        dimView.alpha = 0.0f;
        [container addSubview:dimView];
        
        documentImageView.frame = startFrame;
        [container addSubview:documentImageView];
        
        [UIView animateWithDuration:TRANSITION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             dimView.alpha = 1.0f;
                             documentImageView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             toView.hidden = NO;
                             
                             [dimView removeFromSuperview];
                             [documentImageView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
    else {
        fromView.hidden = YES;
        self.transitionSourceView.hidden = YES;
        
        startFrame = [self transitionTargetFrom:self.transitionSourceView to:toView];
        endFrame = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:container];
        
        dimView.alpha = 1.0f;
        [container addSubview:dimView];
        
        documentImageView.frame = startFrame;
        [container addSubview:documentImageView];
        
        
        
        [UIView animateWithDuration:TRANSITION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                              dimView.alpha = 0.0f;
                             documentImageView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             self.transitionSourceView.hidden = NO;
                             [dimView removeFromSuperview];
                             [documentImageView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}

#pragma mark - Helper

- (CGRect)transitionTargetFrom:(UIView *)from to:(UIView *)to {
    CGFloat scale = [self scaleFrom:from to:to];
    
    CGRect frame = CGRectMake(0, 0, from.bounds.size.width * scale, from.bounds.size.height * scale);
    frame.origin = [self originForTargetPosition:self.targetPosition size:frame.size inContainer:to.bounds.size];
    return frame;
}

- (CGPoint)originForTargetPosition:(PUBTargetPosition)targetPosition
                             size:(CGSize)size
                      inContainer:(CGSize)containerSize {
    if (targetPosition == PUBTargetPositionRight) {
        return CGPointMake(containerSize.width / 2, containerSize.height / 2 - size.height / 2);
    }
    else if (targetPosition == PUBTargetPositionLeft) {
        return CGPointMake(containerSize.width / 2 - size.width, containerSize.height / 2 - size.height / 2);
    }
    else {
        return CGPointMake(containerSize.width / 2 - size.width / 2, containerSize.height / 2 - size.height / 2);
    }
}

- (CGFloat)scaleFrom:(UIView *)from to:(UIView *)to {
    CGFloat widthScale = to.bounds.size.width / from.bounds.size.width;
    CGFloat heightScale = to.bounds.size.height / from.bounds.size.height;
    
    CGFloat scaleAspectFit = MIN(widthScale, heightScale);
    
    return scaleAspectFit;
}

- (BOOL)viewIsLandscape:(UIView *)view {
    return view.frame.size.width >= view.frame.size.height;
}

@end
