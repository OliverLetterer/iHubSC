//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHIssueFeedItemTableViewCell : UITableViewCell {
@private
    IBOutlet UIView *_myContentView;
    IBOutlet UIImageView *_gravatarImageView;
    IBOutlet UILabel *_actorLabel;
    IBOutlet UILabel *_statusLabel;
    IBOutlet UILabel *_repositoryLabel;
    IBOutlet UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, retain) UIImageView *gravatarImageView;
@property (nonatomic, retain) UILabel *actorLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *repositoryLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

+ (CGFloat)height;

@end
