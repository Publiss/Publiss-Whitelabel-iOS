//
//  PUBBaseTransition.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

const CGFloat DURATION_PRESENT = .40f;
const CGFloat DURATION_DISMISS = .35f;

typedef NS_ENUM(NSInteger, TransitionMode) { TransitionModePresent = 0, TransitionModeDismiss };

@interface PUBBaseTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) TransitionMode transitionMode;

@end
