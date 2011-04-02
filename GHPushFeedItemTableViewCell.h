//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedItemTableViewCell.h"

@interface GHPushFeedItemTableViewCell : GHNewsFeedItemTableViewCell {
@private
    UILabel *_firstCommitLabel;
    UILabel *_secondCommitLabel;
}

@property (nonatomic, retain) UILabel *firstCommitLabel;
@property (nonatomic, retain) UILabel *secondCommitLabel;

+ (UIFont *)commitFont;
+ (CGFloat)maxCommitHeight;

@end
