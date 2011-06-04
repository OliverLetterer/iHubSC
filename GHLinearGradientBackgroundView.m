//
//  GHLinearGradientBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 04.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHLinearGradientBackgroundView.h"


@implementation GHLinearGradientBackgroundView

@synthesize colors=_colors;

#pragma mark - setters and getters

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
        [self setNeedsDisplay];
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextDrawLinearGradient(ctx, _gradient, 
                                CGPointMake(CGRectGetWidth(self.bounds)/2.0f, 0.0f), 
                                CGPointMake(CGRectGetWidth(self.bounds)/2.0f, CGRectGetHeight(self.bounds)), 
                                0
                                );
}

#pragma mark - Memory management

- (void)dealloc {
    [_colors release];
    
    if (_gradient) {
        CGGradientRelease(_gradient);
    }
    
    CGColorSpaceRelease(_colorSpace);
    
    [super dealloc];
}

@end
