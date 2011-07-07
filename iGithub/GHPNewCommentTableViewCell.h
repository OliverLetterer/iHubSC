//
//  GHPNewCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPImageDetailTableViewCell.h"

extern CGFloat const GHPNewCommentTableViewCellHeight;

@interface GHPNewCommentTableViewCell : GHPImageDetailTableViewCell {
@private
    UITextView *_textView;
}

@property (nonatomic, retain) UITextView *textView;

@end
