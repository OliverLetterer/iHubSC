//
//  GHLabelTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UITableViewCellWithLinearGradientBackgroundView.h"

@interface GHLabelTableViewCell : UITableViewCellWithLinearGradientBackgroundView {
@private
    UIView *_colorView;
}

@property (nonatomic, retain) UIView *colorView;

@end
