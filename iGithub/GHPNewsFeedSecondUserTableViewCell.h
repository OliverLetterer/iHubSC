//
//  GHPNewsFeedSecondUserTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultNewsFeedTableViewCell.h"

@interface GHPNewsFeedSecondUserTableViewCell : GHPDefaultNewsFeedTableViewCell {
@private
    UIImageView *_secondImageView;
}

@property (nonatomic, retain) UIImageView *secondImageView;

@end
