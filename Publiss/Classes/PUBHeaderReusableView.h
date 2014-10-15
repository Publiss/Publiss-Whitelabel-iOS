//
//  PUBHeaderReusableView.h
//  Publiss
//
//  Created by Denis Andrasec on 15.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBImageReusableView.h"

@interface PUBHeaderReusableView : PUBImageReusableView

@property (nonatomic, copy) void (^singleTapBlock)();
@property (nonatomic, copy) void (^longPressBlock)();

@end
