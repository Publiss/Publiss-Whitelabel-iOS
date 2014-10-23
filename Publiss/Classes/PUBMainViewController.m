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
    return [PUBMainViewController mainViewControllerKioskController:PUBKioskViewController.kioskViewController andMenuController:PUBMenuViewController.menuViewController];
}

+ (REFrostedViewController *)mainViewControllerKioskController:(PUBKioskViewController *)kiosk andMenuController:(PUBMenuViewController *)menu {
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:kiosk menuViewController:menu];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.panGestureEnabled = YES;
    frostedViewController.liveBlur = YES;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleDark;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.menuViewSize = CGSizeMake(240, 0);
    return frostedViewController;
}

@end
