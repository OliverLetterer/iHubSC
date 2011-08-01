//
//  GHPDiffView.h
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDiffViewLineNumbersView.h"
#import "GHPDiffViewContentView.h"

UIFont *GHPDiffViewFont(void);
UIFont *GHPDiffViewBoldFont(void);

@interface GHPDiffView : UIView <NSCoding> {
@private
    UIColor *_borderColor;
    NSString *_diffString;
    GHPDiffViewLineNumbersView *_lineNumbersView;
    GHPDiffViewContentView *_contentDiffView;
    UIScrollView *_scrollView;
}

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, retain) GHPDiffViewLineNumbersView *lineNumbersView;
@property (nonatomic, retain) GHPDiffViewContentView *contentDiffView;
@property (nonatomic, retain) UIScrollView *scrollView;

@end
