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

@class GHAttributedTableViewCell;

@protocol GHIssueTitleTableViewCellDelegate <NSObject>

- (void)issueInfoTableViewCell:(GHAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)issueInfoTableViewCell:(GHAttributedTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHAttributedTableViewCell : GHDescriptionTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextView *_attributedTextView;
    id<GHIssueTitleTableViewCellDelegate> _buttonDelegate;
    
    NSAttributedString *_attributedString;
    NSAttributedString *_selectedAttributesString;
}

@property (nonatomic, retain) DTAttributedTextView *attributedTextView;
@property (nonatomic, assign) id<GHIssueTitleTableViewCellDelegate> buttonDelegate;

@property (nonatomic, retain) NSAttributedString *attributedString;
@property (nonatomic, retain) NSAttributedString *selectedAttributesString;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
