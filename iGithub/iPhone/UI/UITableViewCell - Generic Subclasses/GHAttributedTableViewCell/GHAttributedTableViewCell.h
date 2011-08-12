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
#import "DTLazyImageView.h"

@class GHAttributedTableViewCell;

@protocol GHAttributedTableViewCellDelegate <NSObject>

- (void)attributedTableViewCell:(GHAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button;
- (void)attributedTableViewCellDidChangeBounds:(GHAttributedTableViewCell *)cell;

@optional
- (void)attributedTableViewCell:(GHAttributedTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button;

@end

@interface GHAttributedTableViewCell : GHDescriptionTableViewCell <DTAttributedTextContentViewDelegate, UIActionSheetDelegate, DTLazyImageViewDelegate> {
@private
    DTAttributedTextContentView *_attributedTextView;
    id<GHAttributedTableViewCellDelegate> __weak _buttonDelegate;
    
    NSAttributedString *_attributedString;
    NSAttributedString *_selectedAttributesString;
    
    NSURL *_selectedURL;
    
    NSMutableArray *_lazyImageViews;
}

@property (nonatomic, retain) DTAttributedTextContentView *attributedTextView;
@property (nonatomic, weak) id<GHAttributedTableViewCellDelegate> buttonDelegate;

@property (nonatomic, retain) NSAttributedString *attributedString;
@property (nonatomic, retain) NSAttributedString *selectedAttributesString;

@property (nonatomic, copy) NSURL *selectedURL;

@property (nonatomic, retain, readonly) NSMutableArray *lazyImageViews;


- (void)linkButtonClicked:(DTLinkButton *)sender;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content;

@end
