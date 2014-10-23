//
//  PUBPreviewViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUBParentPreviewViewController.h"

@class PUBDocument;

@interface PUBPreviewViewController : PUBParentPreviewViewController

+ (PUBPreviewViewController *)instantiatePreviewController;

@end
