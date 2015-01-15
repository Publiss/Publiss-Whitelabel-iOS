//
//  PUBLanguageTableViewController.h
//  Publiss
//
//  Created by Lukas Korl on 14/01/15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBDocument.h"

@protocol PUBLanguageSelectionDelegate <NSObject>

- (void)didSelectLanguageForDocument:(PUBDocument *)document;
- (void)didRemoveLanguageForDocument:(PUBDocument *)document;

@end

@interface PUBLanguageTableViewController : UITableViewController

@property (unsafe_unretained) id<PUBLanguageSelectionDelegate> delegate;

+ (PUBLanguageTableViewController *)instantiateLanguageSelectionController;

- (void)setupLanguageSelectionForDocument:(PUBDocument *)document;

@end
