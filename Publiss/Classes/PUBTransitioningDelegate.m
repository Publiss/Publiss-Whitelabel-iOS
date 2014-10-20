//
//  PUBTransitioningDelegate.m
//  Publiss
//
//  Created by Denis Andrasec on 17.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBTransitioningDelegate.h"
#import "PUBBaseTransition.h"
#import "PUBCrossfadeTransition.h"
#import "PUBScaleTransition.h"
#import "PUBDocumentTransition.h"

@interface PUBTransitioningDelegate ()

@property (nonatomic, strong, readwrite) PUBScaleTransition *scaleTransition;
@property (nonatomic, strong, readwrite) PUBCrossfadeTransition *crossfadeTransition;
@property (nonatomic, strong, readwrite) PUBDocumentTransition *documentTransition;

@end

@implementation PUBTransitioningDelegate

#pragma mark - Getter

- (PUBCrossfadeTransition *)crossfadeTransition {
    if (!_crossfadeTransition) {
        _crossfadeTransition = [PUBCrossfadeTransition new];
    }
    return _crossfadeTransition;
}

- (PUBScaleTransition *)scaleTransition {
    if (!_scaleTransition) {
        _scaleTransition = [PUBScaleTransition new];
    }
    return _scaleTransition;
}

- (PUBDocumentTransition *)documentTransition {
    if (!_documentTransition) {
        _documentTransition = [PUBDocumentTransition new];
    }
    return _documentTransition;
}

#pragma mark - Help

- (PUBBaseTransition *)currentTransition {
    if (self.selectedTransition == PUBSelectedTransitionScale) {
        return self.scaleTransition;
    }
    else if (self.selectedTransition == PUBSelectedTransitionDocument) {
        return self.documentTransition;
    }
    else {
        return self.crossfadeTransition;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    PUBBaseTransition *transition = [self currentTransition];
    transition.transitionMode = TransitionModePresent;
    
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.scaleTransition.transitionMode = TransitionModeDismiss;
    
    PUBBaseTransition *transition = [self currentTransition];
    transition.transitionMode = TransitionModeDismiss;
    
    return transition;
}

@end
