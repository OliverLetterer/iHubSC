//
//  GHPDefaultNewsFeedTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPImageDetailTableViewCell.h"

extern CGFloat const GHPDefaultNewsFeedTableViewCellHeight;

@interface GHPDefaultNewsFeedTableViewCell : GHPImageDetailTableViewCell {
@private
    UILabel *_repositoryLabel;
    UILabel *_timeLabel;
}

@property (nonatomic, retain) UILabel *repositoryLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@end
