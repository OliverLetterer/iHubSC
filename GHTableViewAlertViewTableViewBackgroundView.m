//
//  UITableViewAlertViewTableViewBackgroundView.m
//  ExampleApp
//
//  Created by Oliver Letterer on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewAlertViewTableViewBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHTableViewAlertViewTableViewBackgroundView


//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code.
//		// top shadow
//		UIColor *darkShadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
//		UIColor *lightShadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
//		
//		
//		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//		gradientLayer.colors = [NSArray arrayWithObjects:(id)darkShadowColor.CGColor, (id)lightShadowColor.CGColor, nil];
//		gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
//		gradientLayer.frame = CGRectMake(0, 0, frame.size.width, 5.0);
//		[self.layer addSublayer:gradientLayer];
//		
//		gradientLayer = [CAGradientLayer layer];
//		gradientLayer.colors = [NSArray arrayWithObjects:(id)darkShadowColor.CGColor, (id)lightShadowColor.CGColor, nil];
//		gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
//		[gradientLayer setAffineTransform:CGAffineTransformMakeRotation(M_PI/180.0*180.0)];
//		gradientLayer.frame = CGRectMake(0, self.frame.size.height-2.0, frame.size.width, 5.0);
//		[self.layer addSublayer:gradientLayer];
//    }
//    return self;
//}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[super setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *startColor = [UIColor whiteColor];
	UIColor *endColor = [UIColor colorWithWhite:175.0/255.0 alpha:1.0];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat locations[] = { 0.0, 1.0 };
	
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor, nil];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
														(__bridge CFArrayRef) colors, locations);
	
    // More coming... 
	CGPoint startPoint = CGPointMake(CGRectGetMidX(super.bounds), CGRectGetMinY(super.bounds));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(super.bounds), CGRectGetMaxY(super.bounds));
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

@end
