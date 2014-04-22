//
//  PUBDownloadButton.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class PUBDocument;

@interface PUBDownloadButton : UIButton
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)setupDownloadButtonWithPUBDocument:(PUBDocument *)document;
- (void)hideActivityIndicator;
- (void)showActivityIndicator;

@end
