//
//  UITableViewCellWithLinearGradientBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GHLinearGradientBackgroundView;

@interface GHTableViewCellWithLinearGradientBackgroundView : UITableViewCell {
@private
    GHLinearGradientBackgroundView *_linearBackgroundView;
}

@property (nonatomic, retain, readonly) GHLinearGradientBackgroundView *linearBackgroundView;

@property (nonatomic, readonly) UIColor *defaultShadowColor;
@property (nonatomic, readonly) CGSize defaultShadowOffset;

- (UIColor *)shadowColorForView:(UIView *)view;
- (CGSize)shadowOffsetForView:(UIView *)view;

@end
