//
//  PUBDocumentTransition.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocumentTransition.h"
#import "PUBDimmView.h"

@interface PUBDocumentTransition()

@property (nonatomic, strong) UIView *transitionSourceView;

@end

@implementation PUBDocumentTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    CGRect startFrame;
    CGRect endFrame;
    
    PUBDimmView *dimView = [[PUBDimmView alloc] initWithFrame:container.frame];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentTransitionSourceView)]) {
        UIView *transitionSourceView = [self.dataSource currentTransitionSourceView];
        if (transitionSourceView) {
            self.transitionSourceView = transitionSourceView;
        }
    }
    
    if (!self.transitionImage && self.dataSource && [self.dataSource respondsToSelector:@selector(currentTransitionImage)]) {
        UIImage *transitionImage = [self.dataSource currentTransitionImage];
        if (transitionImage) {
            self.transitionImage = transitionImage;
        }
    }
    
    UIImageView *documentImageView = [[UIImageView alloc] initWithImage:self.transitionImage];
    
    if (self.transitionMode == TransitionModePresent) {
        toView.hidden = YES;
        self.transitionSourceView.hidden = YES;
        
        [container addSubview:toView];
        
        startFrame = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:fromView];
        endFrame = [self endFrameWithSourceView:self.transitionSourceView andTargetView:toView];
        
        [self hideNavigationBarOfController:toVC withDuration:DURATION_PRESENT];
        
        dimView.alpha = 0.0f;
        [container addSubview:dimView];
        
        documentImageView.frame = startFrame;
        [container addSubview:documentImageView];
        
        [UIView animateWithDuration:DURATION_PRESENT * 0.8
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             dimView.alpha = 1.0f;
                             documentImageView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             toView.hidden = NO;
                             [dimView removeFromSuperview];
                             
                             [UIView animateWithDuration:DURATION_PRESENT * 0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                 documentImageView.alpha = 0;
                             } completion:^(BOOL finished2) {
                                 [documentImageView removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                             }];
                         }];
    }
    else {
        fromView.hidden = YES;
        self.transitionSourceView.hidden = YES;
        
        startFrame = [self endFrameWithSourceView:self.transitionSourceView andTargetView:toView];
        endFrame = [self.transitionSourceView convertRect:self.transitionSourceView.bounds toView:toView];
        
        if (toView.superview == nil) {
            [container addSubview:toView];
        }
        
        dimView.alpha = 1.0f;
        [container addSubview:dimView];
        
        documentImageView.frame = startFrame;
        [container addSubview:documentImageView];
        
        [UIView animateWithDuration:DURATION_DISMISS * 0.8
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             dimView.alpha = 0.0f;
                             documentImageView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             self.transitionSourceView.hidden = NO;
                             [dimView removeFromSuperview];
                             
                             [UIView animateWithDuration:DURATION_DISMISS * 0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                 documentImageView.alpha = 0;
                             } completion:^(BOOL finished2) {
                                 [documentImageView removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                             }];
                         }];
    }
}

#pragma mark - Helper

- (CGRect)endFrameWithSourceView:(UIView *)sourceView andTargetView:(UIView *)targetView {
    CGFloat scale = [self scaleForTargetPosition:self.targetPosition
                                  withSourceView:sourceView
                                   andTargetView:targetView];
    
    CGRect frame = CGRectMake(0, 0, sourceView.bounds.size.width * scale, sourceView.bounds.size.height * scale);
    frame.origin = [self originForTargetPosition:self.targetPosition size:frame.size inContainer:targetView.bounds.size];
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

- (CGFloat)scaleForTargetPosition:(PUBTargetPosition)targetPosition
                   withSourceView:(UIView *)sourceView
                    andTargetView:(UIView *)targetView {
    if (self.targetPosition == PUBTargetPositionCenter) {
        return [self scalewithAspectFit:sourceView.bounds to:targetView.bounds];
    }
    else {
        CGRect targetFrame = targetView.frame;
        targetFrame.size.width /= 2;
        return [self scalewithAspectFit:sourceView.bounds to:targetFrame];
    }
}

- (CGFloat)scalewithAspectFit:(CGRect )fromRect to:(CGRect )toRect {
    CGFloat widthScale = toRect.size.width / fromRect.size.width;
    CGFloat heightScale = toRect.size.height / fromRect.size.height;
    
    CGFloat scaleAspectFit = MIN(widthScale, heightScale);
    
    return scaleAspectFit;
}

+ (PUBTargetPosition)targetPositionForPageIndex:(NSInteger)pageIndex
                             isDoubleModeActive:(BOOL)doubleModeActive {
    if (doubleModeActive && pageIndex % 2 == 0) {
        return PUBTargetPositionRight;
    }
    else if (doubleModeActive && pageIndex % 2 == 1) {
        return PUBTargetPositionLeft;
    }
    else {
        return PUBTargetPositionCenter;
    }
}

@end
