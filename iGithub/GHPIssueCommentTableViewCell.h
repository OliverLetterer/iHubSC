//
//  GHPIssueCommentTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTAttributedTextView.h"
#import "DTLinkButton.h"
#import "GHPImageDetailTableViewCell.h"

@class GHPIssueCommentTableViewCell;

@protocol GHPIssueCommentTableViewCellDelegate <NSObject>

- (void)commentTableViewCell:(GHPIssueCommentTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)commentTableViewCell:(GHPIssueCommentTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHPIssueCommentTableViewCell : GHPImageDetailTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextView *_attributedTextView;
    
    id<GHPIssueCommentTableViewCellDelegate> _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextView *attributedTextView;
@property (nonatomic, assign) id<GHPIssueCommentTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
