//
//  GHNewsFeedItemTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCellWithLinearGradientBackgroundView.h"

@interface GHNewsFeedItemTableViewCell : GHTableViewCellWithLinearGradientBackgroundView {
@private
    UILabel *_timeLabel;
}

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *repositoryLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@end
