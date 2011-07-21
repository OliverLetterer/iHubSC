//
//  UICollapsingTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCellWithLinearGradientBackgroundView.h"
#import "UIExpandableTableView.h"

@interface GHCollapsingAndSpinningTableViewCell : GHTableViewCellWithLinearGradientBackgroundView <UIExpandingTableViewCell> {
@private
    BOOL _isSpinning;
    
    UIActivityIndicatorView *_activityIndicatorView;
    UIImageView *_disclosureIndicatorImageView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIImageView *disclosureIndicatorImageView;

- (void)setSpinning:(BOOL)spinning;

- (void)setLoading:(BOOL)loading;
- (void)setExpansionStyle:(UIExpansionStyle)style;

@end
