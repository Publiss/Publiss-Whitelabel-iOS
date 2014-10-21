//
//  PUBBaseTransition.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

const CGFloat DURATION_PRESENT = .35f;
const CGFloat DURATION_DISMISS = .30f;

typedef NS_ENUM(NSInteger, TransitionMode) { TransitionModePresent = 0, TransitionModeDismiss };

@interface PUBBaseTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) TransitionMode transitionMode;

- (void)hideNavigationBarOfController:(UIViewController *)controller withDuration:(CGFloat)duration;

@end
