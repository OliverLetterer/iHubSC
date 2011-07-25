//
//  GHPNewCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPImageDetailTableViewCell.h"

#warning inherit from GHNewCommentTableViewCell

extern CGFloat const GHPNewCommentTableViewCellHeight;

@class GHPNewCommentTableViewCell;

@protocol GHPNewCommentTableViewCellDelegate <NSObject>

- (void)newCommentTableViewCell:(GHPNewCommentTableViewCell *)cell didEnterText:(NSString *)text;

@end



@interface GHPNewCommentTableViewCell : GHPImageDetailTableViewCell <UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate> {
@private
    UITextView *_textView;
    
    NSString *_linkText;
    NSString *_linkURL;
    
    id<GHPNewCommentTableViewCellDelegate> _delegate;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, readonly) UIView *textViewInputAccessoryView;

@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) NSString *linkURL;

@property (nonatomic, assign) id<GHPNewCommentTableViewCellDelegate> delegate;


@end
