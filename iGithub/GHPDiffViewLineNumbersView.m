//
//  GHPDiffViewLineNumbersView.m
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDiffViewLineNumbersView.h"
#import "GHPDiffView.h"

@implementation GHPDiffViewLineNumbersView

@synthesize diffOldLinesString=_diffOldLinesString, diffNewLinesString=_diffNewLinesString;
@synthesize borderColor=_borderColor, oldNewTextColor=_oldNewTextColor, linesTextColor=_linesTextColor;

#pragma mark - setters and getters

- (void)setOldLines:(NSString *)diffOldLinesString newLines:(NSString *)diffNewLinesString {
    [_diffOldLinesString release], _diffOldLinesString = [diffOldLinesString copy];
    [_diffNewLinesString release], _diffNewLinesString = [diffNewLinesString copy];
    
    [self setNeedsDisplay];
}

- (CGFloat)width {
    CGSize size1 = [self.diffOldLinesString sizeWithFont:GHPDiffViewFont() 
                                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) 
                                           lineBreakMode:UILineBreakModeWordWrap];
    CGSize size2 = [self.diffNewLinesString sizeWithFont:GHPDiffViewFont() 
                                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) 
                                           lineBreakMode:UILineBreakModeWordWrap];
    
    CGSize size3 = [NSLocalizedString(@"OLD", @"") sizeWithFont:GHPDiffViewBoldFont()];
    CGSize size4 = [NSLocalizedString(@"NEW", @"") sizeWithFont:GHPDiffViewBoldFont()];
    
    return MAX(MAX(size3.height, size4.height), MAX(size1.width, size2.width))*2.0f + 30.0f; 
}

- (void)setFrame:(CGRect)frame {
    CGRect bounds = self.bounds;
    [super setFrame:frame];
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        [self setNeedsDisplay];
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.borderColor = [UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
        self.oldNewTextColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
        self.linesTextColor = [UIColor colorWithRed:144.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1.0f];
        self.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:251.0f/255.0f green:251.0f/255.0f blue:251.0f/255.0f alpha:1.0f].CGColor,
                           (id)[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f].CGColor,
                           nil];
        CGFloat locations[] = {0.0f, 1.0f};
        _oldNewGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.backgroundColor setFill];
    UIRectFill(rect);
    
    CGSize oldSize = [NSLocalizedString(@"OLD", @"") sizeWithFont:GHPDiffViewBoldFont()];
    CGSize newSize = [NSLocalizedString(@"NEW", @"") sizeWithFont:GHPDiffViewBoldFont()];
    
    CGFloat oldNewHeight = MAX(oldSize.height, newSize.height)+10.0f;
    CGPoint startPoint  = CGPointMake(CGRectGetWidth(rect)/2.0f, 0.0f);
    CGPoint endPoint    = CGPointMake(CGRectGetWidth(rect)/2.0f, oldNewHeight);
    
    CGContextDrawLinearGradient(ctx, _oldNewGradient, startPoint, endPoint, 0);
    
    // draw the border
    [self.borderColor setStroke];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.5f, 0.5f, CGRectGetWidth(rect)-1.0f, CGRectGetHeight(rect)-1.0f)];
    [borderPath moveToPoint:CGPointMake(0.0f, oldNewHeight-0.5f)];
    [borderPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), oldNewHeight-0.5f)];
    [borderPath setLineWidth:1.0f];
    [borderPath stroke];
    
    // now draw OLD NEW
    [self.oldNewTextColor setFill];
    [NSLocalizedString(@"OLD", @"") drawInRect:CGRectMake(0.0f, (oldNewHeight-oldSize.height)/2.0f, CGRectGetWidth(rect)/2.0f, oldSize.height) 
                                      withFont:GHPDiffViewBoldFont() 
                                 lineBreakMode:UILineBreakModeClip 
                                     alignment:UITextAlignmentCenter];
    [NSLocalizedString(@"NEW", @"") drawInRect:CGRectMake(CGRectGetWidth(rect)/2.0f, (oldNewHeight-newSize.height)/2.0f, CGRectGetWidth(rect)/2.0f, newSize.height) 
                                      withFont:GHPDiffViewBoldFont() 
                                 lineBreakMode:UILineBreakModeClip 
                                     alignment:UITextAlignmentCenter];
    
    // now draw the lines
    [self.linesTextColor setFill];
    [self.diffOldLinesString drawInRect:CGRectMake(0.0f, oldNewHeight, CGRectGetWidth(rect)/2.0f, CGRectGetHeight(rect)-oldNewHeight)
                               withFont:GHPDiffViewFont() 
                          lineBreakMode:UILineBreakModeWordWrap 
                              alignment:UITextAlignmentCenter];
    [self.diffNewLinesString drawInRect:CGRectMake(CGRectGetWidth(rect)/2.0f, oldNewHeight, CGRectGetWidth(rect)/2.0f, CGRectGetHeight(rect)-oldNewHeight)
                               withFont:GHPDiffViewFont() 
                          lineBreakMode:UILineBreakModeWordWrap 
                              alignment:UITextAlignmentCenter];
}

+ (CGFloat)oldNewHeight {
    CGSize oldSize = [NSLocalizedString(@"OLD", @"") sizeWithFont:GHPDiffViewBoldFont()];
    CGSize newSize = [NSLocalizedString(@"NEW", @"") sizeWithFont:GHPDiffViewBoldFont()];
    
    return MAX(oldSize.height, newSize.height)+10.0f;
}

#pragma mark - Memory management

- (void)dealloc {
    [_diffOldLinesString release];
    [_diffNewLinesString release];
    [_borderColor release];
    [_oldNewTextColor release];
    [_linesTextColor release];
    
    if (_oldNewGradient) {
        CGGradientRelease(_oldNewGradient);
    }
    
    [super dealloc];
}

@end
