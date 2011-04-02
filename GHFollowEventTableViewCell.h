//
//  GHFollowEventTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedItemTableViewCell.h"

@interface GHFollowEventTableViewCell : GHNewsFeedItemTableViewCell {
@private
    UIImageView *_targetImageView;
    UILabel *_targetNameLabel;
}

@property (nonatomic, retain) UIImageView *targetImageView;
@property (nonatomic, retain) UILabel *targetNameLabel;

@end
