//
//  GHPieChartProgressView.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPieChartProgressView.h"
#import "UIColor-Expanded.h"

@implementation GHPieChartProgressView

@synthesize progress=_progress, tintColor=_tintColor;
@synthesize progressLabel=_progressLabel;

#pragma mark - setters and getters

- (void)setProgress:(CGFloat)progress {
    if (progress != _progress) {
        _progress = progress;
        [self setNeedsDisplay];
        
        self.progressLabel.text = [NSString stringWithFormat:@"%d %%", (int)(_progress*100)];
        [self setNeedsLayout];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (tintColor != _tintColor) {
        _tintColor = tintColor;
        [self setNeedsDisplay];
        
        if (_tintGradient) {
            CGGradientRelease(_tintGradient);
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = {0.0f, 1.0f};
        
        NSArray *colors = [NSArray arrayWithObjects:
                           (__bridge id)self.tintColor.CGColor, 
                           (__bridge id)[self.tintColor colorByMultiplyingBy:0.85f].CGColor,
                           nil];
        
        _tintGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        
        CGColorSpaceRelease(colorSpace);
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
        self.backgroundColor = [UIColor clearColor];
        
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.progressLabel.backgroundColor = [UIColor clearColor];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.textAlignment = UITextAlignmentCenter;
        self.progressLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        self.progressLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.progressLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self addSubview:self.progressLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self.progressLabel sizeToFit];
    self.progressLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0f, CGRectGetHeight(self.bounds)/2.0f);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // make background transparent
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    CGRect circleRect = CGRectMake(1.0f, 1.0f, CGRectGetWidth(rect)-2.0f, CGRectGetHeight(rect)-2.0f);
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [circle setLineWidth:1.0f];
    
    // now draw the background of our circle
    [[UIColor lightGrayColor] setFill];
    [circle fill];
    
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, circle.CGPath);
    CGContextClip(ctx);
    
    static CGFloat angleCorrection = -M_PI/2.0f;
    // now display the progress
    CGPoint center = CGPointMake(CGRectGetWidth(rect)/2.0f, CGRectGetHeight(rect)/2.0f);
    CGFloat radius = CGRectGetWidth(rect)/2.0f;
    
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath moveToPoint:CGPointMake(CGRectGetWidth(rect)/2.0f, 0.0f)];
    [progressPath addArcWithCenter:center 
                            radius:radius 
                        startAngle:angleCorrection 
                          endAngle:2.0*M_PI*_progress + angleCorrection
                         clockwise:YES];
    [progressPath addLineToPoint:center];
    [progressPath closePath];
    
    CGContextAddPath(ctx, progressPath.CGPath);
    CGContextClip(ctx);
    
    CGContextDrawRadialGradient(ctx, _tintGradient, center, 0.0f, center, radius, 0);
    
    CGContextRestoreGState(ctx);
    
    // now draw our border
    [[UIColor darkGrayColor] setStroke];
    [circle stroke];
}

#pragma mark - Memory management

- (void)dealloc {
    
    if (_tintGradient) {
        CGGradientRelease(_tintGradient);
    }
    
}

@end
