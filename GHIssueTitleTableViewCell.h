//
//  GHIssueTitleTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHDescriptionTableViewCell.h"
#import "DTAttributedTextView.h"
#import "DTLinkButton.h"

@class GHIssueTitleTableViewCell;

@protocol GHIssueTitleTableViewCellDelegate <NSObject>

- (void)issueInfoTableViewCell:(GHIssueTitleTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)issueInfoTableViewCell:(GHIssueTitleTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHIssueTitleTableViewCell : GHDescriptionTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextView *_attributedTextView;
#warning is misalligned
    
    id<GHIssueTitleTableViewCellDelegate> _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextView *attributedTextView;
@property (nonatomic, assign) id<GHIssueTitleTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
