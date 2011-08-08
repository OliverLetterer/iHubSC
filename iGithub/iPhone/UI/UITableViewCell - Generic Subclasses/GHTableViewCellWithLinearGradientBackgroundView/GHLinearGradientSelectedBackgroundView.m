//
//  GHLinearGradientSelectedBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 08.08.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "GHLinearGradientSelectedBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHLinearGradientSelectedBackgroundView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.colors = [NSArray arrayWithObjects:
                       (__bridge id)[UIColor colorWithRed:40.0f/255.0f green:146.0f/255.0f blue:241.0f/255.0f alpha:1.0f].CGColor, 
                       (__bridge id)[UIColor colorWithRed:0.0f/255.0f green:107.0f/255.0f blue:226.0f/255.0f alpha:1.0f].CGColor,
                       nil];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        NSArray *colors = [NSArray arrayWithObjects:
                           (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor, 
                           (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor, 
                           nil];
        
        CGFloat locations[] = {0.0f, 1.0f};
        _shadowGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat shadowHeight = 5.0f;
    
    CGContextDrawLinearGradient(ctx, _shadowGradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, shadowHeight), 0);
    CGContextDrawLinearGradient(ctx, _shadowGradient, CGPointMake(0.0f, CGRectGetHeight(rect)), CGPointMake(0.0f, CGRectGetHeight(rect) - shadowHeight), 0);
    
}

- (void)dealloc {
    if (_shadowGradient) {
        CGGradientRelease(_shadowGradient), _shadowGradient = NULL;
    }
}

@end
