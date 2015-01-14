//
//  PUBLanguageTableViewController.h
//  Publiss
//
//  Created by Lukas Korl on 14/01/15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBFetchedViewController.h"
#import "PUBDocument.h"

@protocol PUBLanguageSelectionDelegate

- (void)didSelectLanguageForDocument:(PUBDocument *)document;

@end

@interface PUBLanguageTableViewController : UITableViewController

@property (unsafe_unretained) id<PUBLanguageSelectionDelegate> delegate;

+ (UIViewController *)instantiateLanguageSelectionController;

- (void)setupLanguageSelectionForDocument:(PUBDocument *)document;

@end
