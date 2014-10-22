//
//  PUBMainViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMainViewController.h"
#import "REFrostedViewController.h"
#import "PUBKioskViewController.h"
#import "PUBMenuViewController.h"

@interface PUBMainViewController ()

@end

@implementation PUBMainViewController

+ (REFrostedViewController *)mainViewController {
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:PUBKioskViewController.kioskViewController menuViewController:PUBMenuViewController.menuViewController];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.panGestureEnabled = YES;
    frostedViewController.liveBlur = YES;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.menuViewSize = CGSizeMake(240, 0);
    return frostedViewController;
}

@end
