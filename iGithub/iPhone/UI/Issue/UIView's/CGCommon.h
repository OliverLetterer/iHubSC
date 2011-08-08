//
//  CGCommon.h
//  GradientSample
//
//  Created by oliver on 26.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

void DrawGlossGradient(CGContextRef context, CGColorRef color, CGRect inRect);

static inline double radians (double degrees);

CGMutablePathRef CGMutablePathCreateForProgressViewWithRect(CGRect rect);
void CGContextDrawLinearGradientWithColorsInRect(CGContextRef context, NSArray *colors, CGRect rect);
void drawLinearGradient(CGContextRef context, CGRect rect, UIColor *startColor, 
						UIColor *endColor);
