//
//  PUBCenteredScrollView.m
//  PUBCenteredScrollView
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCenteredScrollView.h"

@interface PUBCenteredScrollView () {
    BOOL zoomCheck;
}
@end

@implementation PUBCenteredScrollView

- (void)zoomAtPoint:(CGPoint)viewPoint {
    if (zoomCheck) {
        CGFloat newZoomscale = self.maximumZoomScale;
        CGSize scrollViewSize = self.bounds.size;
        
        CGFloat w = scrollViewSize.width / newZoomscale;
        CGFloat h = scrollViewSize.height / newZoomscale;
        CGFloat x = viewPoint.x - (w / 2.0f);
        CGFloat y = viewPoint.y - (h / 2.0f);
        
        CGRect rectToZoom = CGRectMake(x, y, w, h);
        [self zoomToRect:rectToZoom animated:YES];
        
        [self setZoomScale:newZoomscale animated:YES];
        zoomCheck = NO;
    }
    else {
        [self setZoomScale:self.minimumZoomScale animated:YES];
        zoomCheck = YES;
    }
}


@end
