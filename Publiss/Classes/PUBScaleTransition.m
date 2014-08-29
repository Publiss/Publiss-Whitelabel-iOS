//
//  PUBScaleTransition.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBScaleTransition.h"
#import "PUBConstants.h"

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

    __block UIView *move = nil;
    CGRect beginFrame = [container convertRect:self.cell.coverImage.bounds fromView:self.cell.coverImage];
    CGRect endFrame = toView.bounds;
    CGFloat navBarHeight = self.navigationBar.bounds.size.height + 20.f;
    
    if (self.targetImage) {
        self.magazineImageView = [[UIImageView alloc]initWithImage:self.targetImage];
        self.magazineImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.magazineImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.magazineImageView.frame = self.magazinePageFrame;
        self.magazineImageView.center = toView.center;
    }
    

    if (self.modal) {
        CGFloat width;
        CGFloat height;

        if (self.transitionMode == TransitionModePresent) {
            width = toView.bounds.size.width;
            height = toView.bounds.size.height;
        } else {
            width = fromView.bounds.size.width;
            height = fromView.bounds.size.height;
        }

        if (PUBIsiPad()) {
            endFrame = CGRectMake(CGRectGetMidX(container.bounds) - width / 2.0f,
                                  CGRectGetMidY(container.bounds) - height / 2.0f, width, height);
        }
    }
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            self.cell.hidden = YES;
            toView.frame = endFrame;
            
            if (!self.modal) {
                move = [self.magazineImageView snapshotViewAfterScreenUpdates:YES];
            } else {
                move = [toView snapshotViewAfterScreenUpdates:YES];
            }
            
            
            move.frame = beginFrame;
            [self fixMoveViewRotation:move];
            [container addSubview:move];
            
            self.dimView.hidden = self.modal ? NO : YES;
            
            if (self.modal) {
                [UIView animateWithDuration:.6f
                                      delay:0.f
                     usingSpringWithDamping:PUBIsiPad() ? .8f : 2.5f
                      initialSpringVelocity:17.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.cell.alpha = 0.f;
                                     move.frame = endFrame;
                                     self.dimView.alpha = 0.3f;
                                 }
                                 completion:^(BOOL finished) {
                                     toView.frame = endFrame;
                                     [container addSubview:toView];
                                     [move removeFromSuperview];
                                     [transitionContext completeTransition:YES];
                                 }];
            } else {
                [UIView animateKeyframesWithDuration:.5f
                                               delay:0.f
                                             options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              self.navigationBar.alpha = 0.f;
                                              self.navigationBar.transform = CGAffineTransformMakeTranslation(0.f, -navBarHeight);
                                              self.collectionView.transform = CGAffineTransformMakeScale(.95f, .95f);
                                              self.collectionView.alpha = .0f;
                                              self.cell.alpha = 0.f;
                                              
                                              if ([self isPortrait]) {
                                                  move.frame = self.magazineImageView.frame;
                                              } else {
                                                  move.frame = self.magazineImageView.frame;
                                              }
                                              
                                          } completion:^(BOOL finished) {
                                              self.navigationBar.alpha = 1.f;
                                              self.collectionView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                                              toView.frame = endFrame;
                                              self.navigationBar.transform = CGAffineTransformIdentity;
                                              [container addSubview:toView];
                                              [move removeFromSuperview];
                                              [transitionContext completeTransition:YES];
                                          }];
            }
        }
            break;
            
        case TransitionModeDismiss: {
            move = self.modal ? [fromView snapshotViewAfterScreenUpdates:YES] :
            [self.pageView snapshotViewAfterScreenUpdates:YES];
            [fromView removeFromSuperview];
            
            //  align center view
            move.center = toView.center;
        
            [self fixMoveViewRotation:move];
            [container addSubview:move];
            
            if (self.modal) {
                [UIView animateKeyframesWithDuration:.5f
                                               delay:0.f
                                             options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              move.alpha = 0.f;
                                              move.frame = beginFrame;
                                              self.cell.alpha = 1.f;
                                              self.dimView.alpha = 0.;
                                              self.cell.hidden = NO;
                                              
                                          } completion:^(BOOL finished) {
                                              self.cell.hidden = NO;
                                              self.dimView.hidden = YES;
                                              [move removeFromSuperview];
                                              [transitionContext completeTransition:YES];
                                          }];
            } else {
                [UIView animateKeyframesWithDuration:.4f
                                               delay:0.f
                                             options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              move.alpha = 1.f;
                                              move.frame = beginFrame;
                                              self.cell.alpha = 1.f;
                                              self.collectionView.alpha = 1.f;
                                          } completion:^(BOOL finished) {
                                              self.cell.hidden = NO;
                                              [UIView transitionWithView:self.cell.coverImage
                                                                duration:0.25f
                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                              animations:^{ move.alpha = 0.f; }
                                                              completion:^(BOOL finishes) {
                                                                  [move removeFromSuperview];
                                                                  [transitionContext completeTransition:YES];
                                                              }];
                                          }];
            }
        }
        default:
            break;
    }
}

#pragma mark - Helpers
- (void)fixMoveViewRotation:(UIView *)move {
    switch (UIApplication.sharedApplication.statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            move.transform = CGAffineTransformMakeRotation(-(CGFloat)M_PI / 2.0f);
            break;

        case UIInterfaceOrientationLandscapeRight:
            move.transform = CGAffineTransformMakeRotation((CGFloat)M_PI / 2.0f);
            break;

        case UIInterfaceOrientationPortraitUpsideDown:
            move.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
            break;

        default:
            break;
    }
}

- (BOOL)isPortrait {
    if (UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationPortrait ||
        UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    return NO;
}


@end
