//
//  GHNewsFeedItemTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHNewsFeedItemTableViewCell : UITableViewCell {
@private
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *repositoryLabel;

@end
