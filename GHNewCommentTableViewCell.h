//
//  GHNewCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCell.h"

@interface GHNewCommentTableViewCell : GHTableViewCell {
@private
    UITextView *_textView;
}

@property (nonatomic, retain) UITextView *textView;

@end
