//
//  GHPDiffViewLineNumbersView.h
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHPDiffViewLineNumbersView : UIView <NSCoding> {
@private
    NSString *_diffOldLinesString;
    NSString *_diffNewLinesString;
    
    UIColor *_borderColor;
    UIColor *_oldNewTextColor;
    UIColor *_linesTextColor;
    
    CGGradientRef _oldNewGradient;
}

@property (nonatomic, copy, readonly) NSString *diffOldLinesString;
@property (nonatomic, copy, readonly) NSString *diffNewLinesString;
- (void)setOldLines:(NSString *)diffOldLinesString newLines:(NSString *)diffNewLinesString;

@property (nonatomic, readonly) CGFloat width;

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *oldNewTextColor;
@property (nonatomic, retain) UIColor *linesTextColor;

+ (CGFloat)oldNewHeight;

@end
