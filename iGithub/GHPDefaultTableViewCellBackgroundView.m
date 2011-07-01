//
//  GHPDefaultTableViewCellBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDefaultTableViewCellBackgroundView.h"


@implementation GHPDefaultTableViewCellBackgroundView

@synthesize customStyle=_customStyle, borderPath=_borderPath, colors=_colors;

#pragma mark - setters and getters

- (void)setCustomStyle:(GHPDefaultTableViewCellStyle)customStyle {
    if (customStyle != _customStyle) {
        _customStyle = customStyle;
        [self rebuildBorderPath];
        [self setNeedsDisplay];
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        self.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0].CGColor, 
                       (id)[UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0].CGColor,
                       nil];
        self.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
    }
    return self;
}

- (void)setColors:(NSArray *)colors {
    if (colors != _colors) {
        [_colors release];
        _colors = [colors retain];
        
        CGFloat numberOfColors = (CGFloat) _colors.count;
        
        CGFloat *locations = malloc(sizeof(CGFloat) * numberOfColors);
        
        for (int i = 0; i < numberOfColors; i++) {
            locations[i] = ((CGFloat)i) / numberOfColors;
        }
        
        CGGradientRelease(_gradient);
        _gradient = CGGradientCreateWithColors(_colorSpace, (CFArrayRef)_colors, locations);
        
        free(locations);
        
        [self setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect bounds = self.bounds;
    [super setFrame:frame];
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        [self rebuildBorderPath];
        [self setNeedsDisplay];
    }
}

#pragma mark - drawing

- (void)rebuildBorderPath {
    UIRectCorner corners = 0;
    
    switch (_customStyle) {
        case GHPDefaultTableViewCellStyleTop:
            corners = UIRectCornerTopLeft | UIRectCornerTopRight;
            break;
        case GHPDefaultTableViewCellStyleBottom:
            corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            break;
        case GHPDefaultTableViewCellStyleTopAndBottom:
            corners = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight;
            break;
        case GHPDefaultTableViewCellStyleCenter:
            corners = 0;
            break;
        default:
            break;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(10.0f, 10.0f)];
    self.borderPath = path;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // fill background
    [self.backgroundColor setFill];
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSaveGState(ctx);
    CGPathRef borderPath = self.borderPath.CGPath;
    CGContextAddPath(ctx, borderPath);
    
    CGContextClip(ctx);
    
    CGContextDrawLinearGradient(ctx, _gradient, 
                                CGPointMake(CGRectGetWidth(self.bounds)/2.0f, 0.0f), 
                                CGPointMake(CGRectGetWidth(self.bounds)/2.0f, CGRectGetHeight(self.bounds)), 
                                0
                                );
    CGContextRestoreGState(ctx);
}

#pragma mark - Memory management

- (void)dealloc {
    CGGradientRelease(_gradient);
    CGColorSpaceRelease(_colorSpace);
    [_borderPath release];
    [_colors release];
    [super dealloc];
}

@end
