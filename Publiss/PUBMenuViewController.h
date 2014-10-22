//
//  PUBMenuViewController.h
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PUBMenuViewController : UIViewController

@property (strong, nonatomic) NSArray *menuItems;

+ (PUBMenuViewController *)menuViewController;
+ (PUBMenuViewController *)menuViewControllerWithStoryboardName:(NSString *)storyboard;

@end
