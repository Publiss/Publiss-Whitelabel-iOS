//
//  PUBMainViewController.h
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class REFrostedViewController, PUBKioskViewController, PUBMenuViewController;

@interface PUBMainViewController : UIViewController

+ (REFrostedViewController *)mainViewController;
+ (REFrostedViewController *)mainViewControllerKioskController:(PUBKioskViewController *)kiosk
                                             andMenuController:(PUBMenuViewController *)menu;

@end

