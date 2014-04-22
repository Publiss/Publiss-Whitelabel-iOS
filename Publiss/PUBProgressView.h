//
//  PUBBadgeView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

// Progress view, similar to the app download animation on iOS 7.
@interface PUBProgressView : UIView

// Set the progress. (Default is not animated)
@property (nonatomic, assign) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
