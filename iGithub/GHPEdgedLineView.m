//
//  GHPEdgedLineView.m
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPEdgedLineView.h"


@implementation GHPEdgedLineView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGRect bounds = self.bounds;
    [super setFrame:frame];
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(1.5f, 0.0f, 1.0f, CGRectGetHeight(rect))];
    [[UIColor colorWithWhite:1.0f alpha:0.1f] setStroke];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(0.5f, 0.0f, 1.0f, CGRectGetHeight(rect))];
    [[UIColor colorWithWhite:0.0f alpha:0.15f] setStroke];
    [path stroke];
    
}

#pragma mark - Memory management


@end
