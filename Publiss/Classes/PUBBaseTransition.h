//
//  PUBBaseTransition.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TransitionMode) { TransitionModePresent = 0, TransitionModeDismiss };

@interface PUBBaseTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) TransitionMode transitionMode;

@end
