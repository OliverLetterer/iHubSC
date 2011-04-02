//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHPushFeedItemTableViewCell : UITableViewCell {
@private
    IBOutlet UIView *_myContentView;
    IBOutlet UIImageView *_gravatarImageView;
    IBOutlet UIActivityIndicatorView *_activityIndicatorView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_repositoryLabel;
    IBOutlet UILabel *_firstCommitLabel;
    IBOutlet UILabel *_secondCommitLabel;
}

@property (nonatomic, retain) UIImageView *gravatarImageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *repositoryLabel;
@property (nonatomic, retain) UILabel *firstCommitLabel;
@property (nonatomic, retain) UILabel *secondCommitLabel;

+ (UIFont *)commitFont;
+ (CGFloat)maxCommitHeight;

@end
