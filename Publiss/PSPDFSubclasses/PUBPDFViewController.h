//
//  PUBPDFViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PSPDFKit.h"

@class PUBKioskViewController;

@interface PUBPDFViewController : PSPDFViewController

@property (nonatomic, weak) PUBKioskViewController *kioskViewController;

@end
