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

#warning make attributedTableViewCell:longPressRecognizedForButton: optional and default will show actionSheet to show in safari

@class GHPAttributedTableViewCell;

@protocol GHPAttributedTableViewCellDelegate <NSObject>

- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHPAttributedTableViewCell : GHPImageDetailTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextContentView *_attributedTextView;
    
    id<GHPAttributedTableViewCellDelegate> _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextContentView *attributedTextView;
@property (nonatomic, assign) id<GHPAttributedTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
