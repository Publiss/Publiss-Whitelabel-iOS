//
//  PUBMenuItemAccount.m
//  Publiss
//
//  Created by Lukas Korl on 17/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuItemAccount.h"
#import "PUBAuthentication.h"
#import "UIColor+PUBDesign.h"
#import "UIImage+PUBTinting.h"

@implementation PUBMenuItemAccount

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.icon = [[UIImage imageNamed:@"profile"] imageTintedWithColor:[UIColor publissSecondaryColor] fraction:0.f];
        
        __weak typeof(self) welf = self;
        self.actionBlock = ^() {
            __strong typeof(welf) sself = welf;
            if ([PUBAuthentication.sharedInstance isLoggedIn]) {
                if (sself.actionBlockLogout) {
                    sself.actionBlockLogout();
                }
            }
            else {
                if (sself.actionBlockLogin) {
                    sself.actionBlockLogin();
                }
            }
        };
    }

    return self;
}

- (NSAttributedString *)attributedTitle {
    NSString *title = PUBLocalize(@"Login");
    NSUInteger startUserIndex = title.length;
    PUBAuthentication *auth = PUBAuthentication.sharedInstance;
    
    if ([auth isLoggedIn]) {
        title = PUBLocalize(@"Logout");
        startUserIndex = title.length;
        title = [NSString stringWithFormat:@"%@ %@", title, [[auth getMetadata] objectForKey:PUBAuthentication.sharedInstance.menuItemAccountField]];
        
        NSMutableAttributedString *formattedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        
        [formattedTitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f] range:NSMakeRange(startUserIndex+1, title.length-startUserIndex-1)];

        return formattedTitle;
    }
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setAlignment:NSTextAlignmentLeft];
    [paragraph setLineBreakMode:NSLineBreakByTruncatingHead];
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [attributedTitle length])];
    
    return attributedTitle;
}

@end
