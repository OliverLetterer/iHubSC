//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedItemTableViewCell.h"

@interface GHIssueFeedItemTableViewCell : GHNewsFeedItemTableViewCell {
@private
    UILabel *_descriptionLabel;
}

@property (nonatomic, retain) UILabel *descriptionLabel;

+ (CGFloat)height;

@end
