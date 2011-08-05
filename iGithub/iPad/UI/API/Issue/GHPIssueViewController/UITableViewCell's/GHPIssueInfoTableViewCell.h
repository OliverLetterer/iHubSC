//
//  GHPIssueInfoTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPInfoTableViewCell.h"
#import "DTAttributedTextView.h"
#import "DTLinkButton.h"

@class GHPIssueInfoTableViewCell;

@protocol GHPIssueInfoTableViewCellDelegate <NSObject>

- (void)issueInfoTableViewCell:(GHPIssueInfoTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)issueInfoTableViewCell:(GHPIssueInfoTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHPIssueInfoTableViewCell : GHPInfoTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextContentView *_attributedTextView;
    
    id<GHPIssueInfoTableViewCellDelegate> __weak _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextContentView *attributedTextView;
@property (nonatomic, weak) id<GHPIssueInfoTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content;

@end
