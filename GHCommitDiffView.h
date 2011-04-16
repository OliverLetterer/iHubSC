//
//  GHCommitDiffView.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class GHCommitDiffView;

@protocol GHCommitDiffViewDelegate <NSObject>

- (void)commitDiffViewDidParseText:(GHCommitDiffView *)commitDiffView;

@end

@interface GHCommitDiffView : UIView {
@private
    NSString *_diffString;
    NSMutableAttributedString *_attributedString;
    CTFramesetterRef _frameSetter;  // retained
    CGSize _suggestedSize;
    id<GHCommitDiffViewDelegate> _delegate;
}

@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, retain) NSMutableAttributedString *attributedString;
@property (nonatomic, assign) id<GHCommitDiffViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame diffString:(NSString *)diffString delegate:(id<GHCommitDiffViewDelegate>)delegate;

@end
