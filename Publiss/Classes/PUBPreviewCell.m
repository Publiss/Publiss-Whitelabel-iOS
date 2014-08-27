//
//  PUBPreviewCell.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPreviewCell.h"
#import "PUBCenteredScrollView.h"
#import "PUBConstants.h"

@implementation PUBPreviewCell

#define Y_OFFSET_IPHONE 18.f
#define Y_OFFSET_IPAD 0.f

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [NSBundle.mainBundle loadNibNamed:@"PreviewCell" owner:self options:nil];
        self = [arrayOfViews.firstObject isKindOfClass:UICollectionViewCell.class] ? arrayOfViews.firstObject : nil;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.bounces = NO;
    self.activityIndicator = [UIActivityIndicatorView new];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.frame = CGRectMake(self.contentView.center.x - 10.f, self.contentView.center.y - 10.f, 20.f, 20.f);
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.scrollView addSubview:self.previewImageView];
    [self insertSubview:self.activityIndicator aboveSubview:self.scrollView];
    
    self.activityIndicator.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = self.bounds.size;
    
    if (self.previewImageView.image != nil) {
        CGFloat width;
        CGFloat height;
        CGFloat ratio = self.previewImageView.image.size.width / self.previewImageView.image.size.height;
        if (ratio > 1) {
            width = self.bounds.size.width;
            height = self.bounds.size.height / ratio;
        } else {
            width = self.bounds.size.width * ratio;
            height = self.bounds.size.height;
        }
        
        self.previewImageView.frame = CGRectMake(0.0f, 0.0f, width, height);
        
        if (PUBIsiPad()) {
            self.previewImageView.center =
            CGPointMake(CGRectGetWidth(self.bounds) / 2.0f,
                        (CGRectGetHeight(self.bounds)- CGRectGetHeight(self.previewImageView.bounds) / 2.0f) + Y_OFFSET_IPAD);
        } else {
            self.previewImageView.center =
            CGPointMake(CGRectGetWidth(self.bounds) / 2.0f,
                        (CGRectGetHeight(self.bounds)- CGRectGetHeight(self.previewImageView.bounds) / 2.0f) + Y_OFFSET_IPHONE);
        }
    }
    self.scrollView.bounds = self.bounds;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _previewImageView;
}

- (void)enableZooming {
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.previewImageView;
}

- (UIImageView *)coverImage {
    return self.previewImageView;
}

@end
