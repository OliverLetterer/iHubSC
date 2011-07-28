//
//  INProgressView.m
//  GradientSample
//
//  Created by oliver on 26.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "INProgressView.h"
#import "CGCommon.h"

@interface INProgressView (private)

- (void)_updatePathes;
- (void)_updateBackgroundColor;
- (void)_updateTintColorWithColor:(UIColor *)color;
- (void)_updateProgressRect;

@end

@implementation INProgressView (private)

- (void)_updatePathes {
	CGMutablePathRef outerPath = CGMutablePathCreateForProgressViewWithRect(self.bounds);
	self.outerPath = (__bridge id)outerPath;
	CGPathRelease(outerPath);
	
	CGRect innerRect = CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);
	CGMutablePathRef innerPath = CGMutablePathCreateForProgressViewWithRect(innerRect);
	self.innerPath = (__bridge id)innerPath;
	CGPathRelease(innerPath);
}

- (void)_updateBackgroundColor {
	UIGraphicsBeginImageContext(CGSizeMake(1, self.bounds.size.height));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGColorRef blackColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor; 
	CGColorRef darkGrayColor = [UIColor colorWithRed:88.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0].CGColor;
	
	drawLinearGradient(ctx, CGRectMake(0, 0, 2, self.bounds.size.height), blackColor, darkGrayColor);
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.progressBarBackgroundColor = [UIColor colorWithPatternImage:backgroundImage];
}

- (void)_updateTintColorWithColor:(UIColor *)color {
	UIGraphicsBeginImageContext(CGSizeMake(1, self.bounds.size.height));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	DrawGlossGradient(ctx, color.CGColor, CGRectMake(0, 0, 1, self.bounds.size.height));
	
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.progressBarTintColor = [UIColor colorWithPatternImage:backgroundImage];
}

- (void)_updateProgressRect {
	_progressRect = CGRectMake(0, 0, self.bounds.size.width * _progress, self.bounds.size.height);
}

@end



@implementation INProgressView

@synthesize progress=_progress;
@synthesize outerPath=_outerPath, innerPath=_innerPath;
@synthesize progressBarBackgroundColor=_progressBarBackgroundColor, progressBarTintColor=_progressBarTintColor, tintColor=_tintColor;

#pragma mark -
#pragma mark setters and getters

- (void)setTintColor:(UIColor *)color {
	if (color != _tintColor) {
		_tintColor = color;
		[self _updateTintColorWithColor:_tintColor];
		[self setNeedsDisplay];
	}
}

- (void)setProgress:(CGFloat)progress {
	_progress = progress;
	[self _updateProgressRect];
	[self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
	CGRect oldFrame = self.frame;
	[super setFrame:frame];
	
	BOOL needsDisplay = NO;
	
	if (oldFrame.size.width != frame.size.width) {
		needsDisplay = YES;
		[self _updatePathes];
		[self _updateProgressRect];
	}
	if (oldFrame.size.height != frame.size.height) {
		needsDisplay = YES;
		[self _updatePathes];
		[self _updateBackgroundColor];
		[self _updateTintColorWithColor:self.tintColor];
		[self _updateProgressRect];
	}
	
	if (needsDisplay) {
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark view related

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		super.backgroundColor = [UIColor clearColor];
		[self _updatePathes];
		[self _updateBackgroundColor];
		self.tintColor = [UIColor colorWithRed:20.0/255.0 green:51.0/255.0 blue:255.0/255.0 alpha:1.0];
		[self _updateTintColorWithColor:self.tintColor];
		[self _updateProgressRect];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// draw Background
	CGContextSaveGState(context);
	CGContextAddPath(context, (__bridge CGMutablePathRef)self.outerPath);
	CGContextClip(context);
	
	CGContextSetFillColorWithColor(context, self.progressBarBackgroundColor.CGColor);
	CGContextFillRect(context, self.bounds);
	
	CGContextRestoreGState(context);
	
	
	// draw progressBar
	
	CGContextSaveGState(context);
	CGContextAddPath(context, (__bridge CGMutablePathRef)self.innerPath);
	CGContextClip(context);
	
	CGContextSetFillColorWithColor(context, self.progressBarTintColor.CGColor);
	CGContextFillRect(context, _progressRect);
	
	CGContextRestoreGState(context);
	
}



@end
