//
//  GHIssueCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "DTLinkButton.h"
#import "DTAttributedTextView.h"

@class GHIssueCommentTableViewCell;

@protocol GHIssueCommentTableViewCellDelegate <NSObject>

- (void)commentTableViewCell:(GHIssueCommentTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)commentTableViewCell:(GHIssueCommentTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHIssueCommentTableViewCell : GHFeedItemWithDescriptionTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextView *_attributedTextView;
    
    id<GHIssueCommentTableViewCellDelegate> _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextView *attributedTextView;
@property (nonatomic, assign) id<GHIssueCommentTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
