//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHPUserInfoTableViewCell;

@protocol GHPUserInfoTableViewCellDelegate <NSObject>

- (void)userInfoTableViewCellActionButtonClicked:(GHPUserInfoTableViewCell *)cell;

@end

@interface GHPUserInfoTableViewCell : UITableViewCell {
@private
    UIButton *_actionButton;
    UIActivityIndicatorView *_activityIndicatorView;
    id<GHPUserInfoTableViewCellDelegate> _delegate;
}

@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) id<GHPUserInfoTableViewCellDelegate> delegate;

@end
