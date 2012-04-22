//
//  GHPCollapsingAndSpinningTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"
#import "UIExpandableTableView.h"

@interface GHPCollapsingAndSpinningTableViewCell : GHPDefaultTableViewCell <UIExpandingTableViewCell> {
@private
    BOOL _isSpinning;
    
    UIActivityIndicatorView *_activityIndicatorView;
    UIImageView *_disclosureIndicatorImageView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIImageView *disclosureIndicatorImageView;

@end
