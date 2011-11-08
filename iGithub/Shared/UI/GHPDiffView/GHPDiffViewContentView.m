//
//  GHPDiffViewContentView.m
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDiffViewContentView.h"
#import "GHPDiffView.h"
#import "GHPDiffViewLineNumbersView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHPDiffViewContentView

@synthesize diffString=_diffString;
@synthesize width=_width;

#pragma mark - setters and getters

- (void)setDiffString:(NSString *)diffString {
    _diffString = [diffString copy];
    
    __block CGFloat width = 0.0f;
    [_diffString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        CGSize size = [line sizeWithFont:GHPDiffViewFont() 
                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) 
                           lineBreakMode:UILineBreakModeWordWrap];
        width = MAX(width, size.width);
    }];
    _width = width;
    [self setNeedsDisplay];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.layer.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    __block CGFloat offset = 0.0f;
    __block BOOL firstLineInfoString = YES;
    [_diffString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        UIFont *font = GHPDiffViewFont();
        
        CGSize size = [line sizeWithFont:font 
                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) 
                           lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat backgroundHeight = size.height;
        
        UIColor *fillColor = [UIColor whiteColor];
        if ([line hasPrefix:@"+"]) {
            fillColor = [UIColor colorWithRed:227.0f/255.0f green:251.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
        } else if ([line hasPrefix:@"-"]) {
            fillColor = [UIColor colorWithRed:250.0f/255.0f green:223.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
        } else if ([line hasPrefix:@"@@"]) {
            if (firstLineInfoString) {
                backgroundHeight = [GHPDiffViewLineNumbersView oldNewHeight];
                firstLineInfoString = NO;
            }
            fillColor = [UIColor clearColor];
        }
        
        CGRect backgroundRect = CGRectMake(0.0f, offset, CGRectGetWidth(rect), backgroundHeight);
        
        [fillColor setFill];
        UIRectFill(backgroundRect);
        
        [[UIColor darkGrayColor] setFill];
        if ([line hasPrefix:@"@@"]) {
            [[UIColor grayColor] setFill];
        }
        [line drawInRect:CGRectMake(0.0f, offset + (backgroundHeight - size.height)/2.0f, CGRectGetWidth(backgroundRect), size.height) 
                withFont:GHPDiffViewFont() lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        
        offset += backgroundHeight;
    }];
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_diffString forKey:@"diffString"];
    [encoder encodeFloat:_width forKey:@"width"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _diffString = [decoder decodeObjectForKey:@"diffString"];
        _width = [decoder decodeFloatForKey:@"width"];
    }
    return self;
}

@end
