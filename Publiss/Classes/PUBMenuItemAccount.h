//
//  PUBMenuItemAccount.h
//  Publiss
//
//  Created by Lukas Korl on 17/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuItem.h"

@interface PUBMenuItemAccount : PUBMenuItem

@property (nonatomic, copy) void(^actionBlockLogin)();
@property (nonatomic, copy) void(^actionBlockLogout)();

@end
