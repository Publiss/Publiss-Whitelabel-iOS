//
//  PUBTransitioningDelegate.h
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PUBScaleTransition, PUBFadeTransition, PUBDocumentTransition;

typedef NS_ENUM(NSInteger, PUBSelectedTransition) {
    PUBSelectedTransitionFade = 0,
    PUBSelectedTransitionScale,
    PUBSelectedTransitionDocument,
};

@interface PUBTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong, readonly) PUBScaleTransition *scaleTransition;
@property (nonatomic, strong, readonly) PUBFadeTransition *fadeTransition;
@property (nonatomic, strong, readonly) PUBDocumentTransition *documentTransition;

@property (nonatomic, assign) PUBSelectedTransition selectedTransition;

@end
