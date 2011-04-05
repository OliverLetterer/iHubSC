//
//  UICollapsingTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCellWithLinearGradientBackgroundView.h"

@interface UICollapsingAndSpinningTableViewCell : UITableViewCellWithLinearGradientBackgroundView {
@private
    BOOL _isSpinning;
    
    UIActivityIndicatorView *_activityIndicatorView;
    UIImageView *_disclosureIndicatorImageView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIImageView *disclosureIndicatorImageView;

- (void)setSpinning:(BOOL)spinning;

@end
