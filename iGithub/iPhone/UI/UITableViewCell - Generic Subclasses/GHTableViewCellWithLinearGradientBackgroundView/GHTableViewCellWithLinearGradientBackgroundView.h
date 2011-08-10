//
//  UITableViewCellWithLinearGradientBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GHLinearGradientBackgroundView, GHLinearGradientSelectedBackgroundView;

@interface GHTableViewCellWithLinearGradientBackgroundView : UITableViewCell {
@private
    GHLinearGradientBackgroundView *_linearBackgroundView;
    GHLinearGradientSelectedBackgroundView *_selectedLinearGradientView;
}

@property (nonatomic, retain, readonly) GHLinearGradientBackgroundView *linearBackgroundView;
@property (nonatomic, retain, readonly) GHLinearGradientSelectedBackgroundView *selectedLinearGradientView;

@end
