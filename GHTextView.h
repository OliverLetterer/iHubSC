//
//  GHTextView.h
//  iGithub
//
//  Created by Oliver Letterer on 19.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class GHTextView;

@protocol GHTextViewDelegate <NSObject>

- (void)textViewDidParseText:(GHTextView *)textView;
- (NSAttributedString *)textView:(GHTextView *)textView formattedLineFromText:(NSString *)line;

@end

@interface GHTextView : UIView {
@private
    NSString *_text;
    NSMutableAttributedString *_attributedString;
    CTFramesetterRef _frameSetter;  // retained
    CGSize _suggestedSize;
    id<GHTextViewDelegate> _delegate;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableAttributedString *attributedString;
@property (nonatomic, assign) id<GHTextViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text delegate:(id<GHTextViewDelegate>)delegate;

@end
