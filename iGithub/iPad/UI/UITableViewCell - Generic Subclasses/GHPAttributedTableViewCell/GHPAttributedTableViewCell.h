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
#import "DTLazyImageView.h"

@class GHPAttributedTableViewCell;

@protocol GHPAttributedTableViewCellDelegate <NSObject>
- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)attributedTableViewCellDidChangeBounds:(GHPAttributedTableViewCell *)cell;

@optional
- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;
@end

@interface GHPAttributedTableViewCell : GHPImageDetailTableViewCell <DTAttributedTextContentViewDelegate, UIActionSheetDelegate, DTLazyImageViewDelegate> {
@private
    DTAttributedTextContentView *_attributedTextView;
    NSURL *_selectedURL;
    
    id<GHPAttributedTableViewCellDelegate> __weak _buttonDelegate;
    
    NSMutableArray *_lazyImageViews;
}

@property (nonatomic, retain) DTAttributedTextContentView *attributedTextView;
@property (nonatomic, copy) NSURL *selectedURL;
@property (nonatomic, weak) id<GHPAttributedTableViewCellDelegate> buttonDelegate;

@property (nonatomic, retain, readonly) NSMutableArray *lazyImageViews;

- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content;

@end
