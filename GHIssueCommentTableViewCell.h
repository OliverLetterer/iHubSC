//
//  GHIssueCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHIssueCommentTableViewCell : UITableViewCell {
@private
    UILabel *_timeDetailsLabel;
}

@property (nonatomic, retain) UILabel *timeDetailsLabel;

@end
