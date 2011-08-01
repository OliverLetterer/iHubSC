//
//  GHNewCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCell.h"

extern CGFloat const GHNewCommentTableViewCellHeight;
extern NSInteger const GHNewCommentTableViewCellSubmitButtonTag;

@class GHNewCommentTableViewCell;

@protocol GHNewCommentTableViewCellDelegate <NSObject>

- (void)newCommentTableViewCell:(GHNewCommentTableViewCell *)cell didEnterText:(NSString *)text;

@end



@interface GHNewCommentTableViewCell : GHTableViewCell <UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate> {
@private
    UITextView *_textView;
    
    NSString *_linkText;
    NSString *_linkURL;
    
    id<GHNewCommentTableViewCellDelegate> __weak _delegate;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, readonly) UIView *textViewInputAccessoryView;

@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) NSString *linkURL;

@property (nonatomic, weak) id<GHNewCommentTableViewCellDelegate> delegate;

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarInsertButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarFormatButtonClicked:(UIBarButtonItem *)barButton;

@end
