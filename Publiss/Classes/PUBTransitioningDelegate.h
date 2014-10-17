//
//  PUBTransitioningDelegate.h
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PUBScaleTransition, PUBCrossfadeTransition;

typedef NS_ENUM(NSInteger, PUBSelectedTransition) {
    PUBSelectedTransitionCrossfade = 0,
    PUBSelectedTransitionScale,
};

@interface PUBTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readonly) PUBScaleTransition *scaleTransition;
@property (nonatomic, strong, readonly) PUBCrossfadeTransition *crossfadeTransition;

@property (nonatomic, assign) PUBSelectedTransition selectedTransition;

@end
