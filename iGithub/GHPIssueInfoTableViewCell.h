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

@end

@interface GHPIssueInfoTableViewCell : GHPInfoTableViewCell <DTAttributedTextContentViewDelegate> {
@private
    DTAttributedTextView *_attributedTextView;
    
    id<GHPIssueInfoTableViewCellDelegate> _buttonDelegate;
}

@property (nonatomic, retain) DTAttributedTextView *attributedTextView;
@property (nonatomic, assign) id<GHPIssueInfoTableViewCellDelegate> buttonDelegate;

- (void)linkButtonClicked:(DTLinkButton *)sender;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView;

@end
