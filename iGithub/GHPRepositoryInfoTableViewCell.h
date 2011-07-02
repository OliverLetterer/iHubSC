//
//  GHPRepositoryInfoTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+GHHeight.h"

@class GHPRepositoryInfoTableViewCell;

@protocol GHPRepositoryInfoTableViewCellDelegate <NSObject>

- (void)repositoryInfoTableViewCellActionButtonClicked:(GHPRepositoryInfoTableViewCell *)cell;

@end

@interface GHPRepositoryInfoTableViewCell : UITableViewCell {
@private
    UIButton *_actionButton;
    UIActivityIndicatorView *_activityIndicatorView;
    id<GHPRepositoryInfoTableViewCellDelegate> _delegate;
}

@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) id<GHPRepositoryInfoTableViewCellDelegate> delegate;

@end