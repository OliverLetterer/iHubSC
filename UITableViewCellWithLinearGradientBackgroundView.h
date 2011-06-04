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

@interface UITableViewCellWithLinearGradientBackgroundView : UITableViewCell {
@private
    GHLinearGradientBackgroundView *_linearBackgroundView;
}

@property (nonatomic, retain, readonly) GHLinearGradientBackgroundView *linearBackgroundView;

@end
