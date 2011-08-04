//
//  ANNotificationQueueWindow.m
//  iGithub
//
//  Created by Oliver Letterer on 04.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANNotificationQueueWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "ANNotificationQueueRootViewController.h"

@implementation ANNotificationQueueWindow

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        //        self.layer.needsDisplayOnBoundsChange = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.needsDisplayOnBoundsChange = YES;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        NSArray *colors = [NSArray arrayWithObjects:(__bridge id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor, 
                           (__bridge id)[UIColor colorWithWhite:0.0f alpha:1.0f].CGColor, 
                           nil];
        
        CGFloat locations[] = {0.0f, 1.0f};
        _gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        CGColorSpaceRelease(colorSpace);
        
        self.rootViewController = [[ANNotificationQueueRootViewController alloc] init];
        self.windowLevel = UIWindowLevelAlert;
        self.userInteractionEnabled = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(CGRectGetWidth(rect)/2.0f, CGRectGetHeight(rect)/2.0f);
    CGFloat radius = MAX(CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    CGContextDrawRadialGradient(ctx, _gradient, center, 0.0f, center, radius, 0);
}

- (void)dealloc {
    if (_gradient) {
        CGGradientRelease(_gradient);
    }
}

@end
