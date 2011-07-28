//
//  UITableViewCell+Background.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableViewCell+Background.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITableViewCell (GHBackground)

- (void)setBackgroundShadowHeight:(CGFloat)height {
    
    if (self.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (CALayer *layer in self.selectedBackgroundView.layer.sublayers) {
        if ([layer isKindOfClass:NSClassFromString(@"CAGradientLayer")]) {
            [array addObject:layer];
        }
    }
    for (CALayer *layer in array) {
        [layer removeFromSuperlayer];
    }
    
    CGFloat totaHeight = self.selectedBackgroundView.bounds.size.height;
    
    CAGradientLayer *gradientLayer = nil;
    CGColorRef topShadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    CGColorRef bottomShadowColor = [UIColor colorWithWhite:0.0 alpha:0.0].CGColor;
    CGFloat shadowHeight = height;
    CGFloat shadowWidth = height;
    
    // top shadow layer
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)topShadowColor, 
                            (__bridge id)bottomShadowColor, 
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1.0], 
                               nil];
    gradientLayer.frame = CGRectMake(0.0, 0.0, 320.0, shadowHeight);
    [self.selectedBackgroundView.layer addSublayer:gradientLayer];
    
    // bottom shadow layer
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)topShadowColor, 
                            (__bridge id)bottomShadowColor, 
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1.0], 
                               nil];
    gradientLayer.transform = CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0);
    gradientLayer.frame = CGRectMake(0.0, totaHeight-shadowHeight, 320.0, shadowHeight);
    [self.selectedBackgroundView.layer addSublayer:gradientLayer];
    
    // left shadow layer
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)topShadowColor, 
                            (__bridge id)bottomShadowColor, 
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1.0], 
                               nil];
    gradientLayer.transform = CATransform3DMakeRotation(M_PI/2.0*3.0, 0.0, 0.0, 1.0);
    gradientLayer.frame = CGRectMake(0.0, 0.0, shadowWidth, totaHeight);
    [self.selectedBackgroundView.layer addSublayer:gradientLayer];
    
    // right shadow layer
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)topShadowColor, 
                            (__bridge id)bottomShadowColor, 
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1.0], 
                               nil];
    gradientLayer.transform = CATransform3DMakeRotation(M_PI/2.0, 0.0, 0.0, 1.0);
    gradientLayer.frame = CGRectMake(320.0-shadowWidth, 0.0, shadowWidth, totaHeight);
    [self.selectedBackgroundView.layer addSublayer:gradientLayer];
}

@end
