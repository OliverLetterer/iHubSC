//
//  GHPInfoTableViewCellDelegate.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+GHHeight.h"

@class GHPInfoTableViewCell;

@protocol GHPInfoTableViewCellDelegate <NSObject>

- (void)infoTableViewCellActionButtonClicked:(GHPInfoTableViewCell *)cell;

@end

@interface GHPInfoTableViewCell : UITableViewCell {
@private
    UIButton *_actionButton;
    UIActivityIndicatorView *_activityIndicatorView;
    id<GHPInfoTableViewCellDelegate> _delegate;
}

@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) id<GHPInfoTableViewCellDelegate> delegate;

@end