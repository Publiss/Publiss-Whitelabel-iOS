//
//  PUBLanguageSelectionCell.h
//  Publiss
//
//  Created by Lukas Korl on 15/01/15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUBDocument.h"

@interface PUBLanguageSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *readButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (void)setupCellForDocument:(PUBDocument *)document;

@end
