//
//  CGCommon.m
//  GradientSample
//
//  Created by oliver on 26.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CGCommon.h"


typedef struct
{
    float color[4];
    float caustic[4];
    float expCoefficient;
    float expScale;
    float expOffset;
    float initialWhite;
    float finalWhite;
} GlossParameters;

static void perceptualCausticColorForColor(float *inputComponents, float *outputComponents);
static void glossInterpolation(void *info, const float *input, float *output);
static float perceptualGlossFractionForColor(float *inputComponents);
static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );
void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );


void DrawGlossGradient(CGContextRef context, CGColorRef color, CGRect inRect)
{
    const float EXP_COEFFICIENT = 1.2;
    const float REFLECTION_MAX = 0.60;
    const float REFLECTION_MIN = 0.20;
	
    GlossParameters params;
	
    params.expCoefficient = EXP_COEFFICIENT;
    params.expOffset = expf(-params.expCoefficient);
    params.expScale = 1.0 / (1.0 - params.expOffset);
	
	//    UIColor *source = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGColorRef source = color;
	
	memcpy(params.color, CGColorGetComponents(source), CGColorGetNumberOfComponents(source) * sizeof(CGFloat));
	
    if (CGColorGetNumberOfComponents(source) == 3)
    {
        params.color[3] = 1.0;
    }
	
    perceptualCausticColorForColor(params.color, params.caustic);
	
    float glossScale = perceptualGlossFractionForColor(params.color);
	
    params.initialWhite = glossScale * REFLECTION_MAX;
    params.finalWhite = glossScale * REFLECTION_MIN;
	
    static const float input_value_range[2] = {0, 1};
    static const float output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    CGFunctionCallbacks callbacks = {0, glossInterpolation, NULL};
	
    CGFunctionRef gradientFunction = CGFunctionCreate(
													  (void *)&params,
													  1, // number of input values to the callback
													  input_value_range,
													  4, // number of components (r, g, b, a)
													  output_value_ranges,
													  &callbacks);
	
    CGPoint startPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMinY(inRect));
    CGPoint endPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMaxY(inRect));
	
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint,
												endPoint, gradientFunction, FALSE, FALSE);
	
    CGContextSaveGState(context);
    CGContextClipToRect(context, inRect);
    CGContextDrawShading(context, shading);
    CGContextRestoreGState(context);
	
    CGShadingRelease(shading);
    CGColorSpaceRelease(colorspace);
    CGFunctionRelease(gradientFunction);
}

static void glossInterpolation(void *info, const float *input,
							   float *output)
{
    GlossParameters *params = (GlossParameters *)info;
	
    float progress = *input;
    if (progress < 0.5)
    {
        progress = progress * 2.0;
		
        progress =
		1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);
		
        float currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
		
        output[0] = params->color[0] * (1.0 - currentWhite) + currentWhite;
        output[1] = params->color[1] * (1.0 - currentWhite) + currentWhite;
        output[2] = params->color[2] * (1.0 - currentWhite) + currentWhite;
        output[3] = params->color[3] * (1.0 - currentWhite) + currentWhite;
    }
    else
    {
        progress = (progress - 0.5) * 2.0;
		
        progress = params->expScale *
		(expf((1.0 - progress) * -params->expCoefficient) - params->expOffset);
		
        output[0] = params->color[0] * (1.0 - progress) + params->caustic[0] * progress;
        output[1] = params->color[1] * (1.0 - progress) + params->caustic[1] * progress;
        output[2] = params->color[2] * (1.0 - progress) + params->caustic[2] * progress;
        output[3] = params->color[3] * (1.0 - progress) + params->caustic[3] * progress;
    }
}


static void perceptualCausticColorForColor(float *inputComponents, float *outputComponents)
{
    const float CAUSTIC_FRACTION = 0.60;
    const float COSINE_ANGLE_SCALE = 1.4;
    const float MIN_RED_THRESHOLD = 0.95;
    const float MAX_BLUE_THRESHOLD = 0.7;
    const float GRAYSCALE_CAUSTIC_SATURATION = 0.2;
	
    float hue, saturation, brightness;
	
	RGBtoHSV(inputComponents[0], inputComponents[1], inputComponents[2], &hue, &saturation, &brightness);
	
	
	float targetHue, targetSaturation, targetBrightness;
	
	
	CGColorRef theYellow = [[UIColor yellowColor] CGColor];
	const CGFloat *theYellowComponents = CGColorGetComponents(theYellow);
	RGBtoHSV(theYellowComponents[0], theYellowComponents[1], theYellowComponents[2], &targetHue, &targetSaturation, &targetBrightness);
	
	
    if (saturation < 1e-3)
    {
        hue = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }
	
    if (hue > MIN_RED_THRESHOLD)
    {
        hue -= 1.0;
    }
    else if (hue > MAX_BLUE_THRESHOLD)
    {
		CGColorRef theMagenta = [[UIColor magentaColor] CGColor];
		const CGFloat *theMagentaComponents = CGColorGetComponents(theMagenta);
		RGBtoHSV(theMagentaComponents[0], theMagentaComponents[1], theMagentaComponents[2], &targetHue, &targetSaturation, &targetBrightness);
		
    }
	
    float scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue)));
	
	hue = hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic;
	brightness = brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic;
	
	HSVtoRGB(&outputComponents[0], &outputComponents[1], &outputComponents[2], hue, saturation, brightness);
	outputComponents[3] = inputComponents[3];
}

static float perceptualGlossFractionForColor(float *inputComponents)
{
    const float REFLECTION_SCALE_NUMBER = 0.2;
    const float NTSC_RED_FRACTION = 0.299;
    const float NTSC_GREEN_FRACTION = 0.587;
    const float NTSC_BLUE_FRACTION = 0.114;
	
    float glossScale =
	NTSC_RED_FRACTION * inputComponents[0] +
	NTSC_GREEN_FRACTION * inputComponents[1] +
	NTSC_BLUE_FRACTION * inputComponents[2];
    glossScale = pow(glossScale, REFLECTION_SCALE_NUMBER);
    return glossScale;
}

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
	float min, max, delta;
	min = MIN( r, MIN(g, b) );
	max = MAX( r, MAX(g, b) );
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
	
	*h /= 360; 
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	h *= 360; 
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

static inline double radians (double degrees) { return degrees * M_PI/180; }

CGMutablePathRef CGMutablePathCreateForProgressViewWithRect(CGRect rect) {
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGFloat radius = rect.size.height/2.0f;
	
	CGPoint topLeftPoint = CGPointMake(rect.origin.x + radius, rect.origin.y);
	CGPoint topRightPoint = CGPointMake(rect.origin.x + rect.size.width - radius, rect.origin.y);
	
	CGPoint bottomLeftPoint = CGPointMake(topLeftPoint.x, rect.origin.y + rect.size.height);
	
	CGPoint rightArcCenterPoint = CGPointMake(topRightPoint.x, rect.origin.y + radius);
	CGPoint leftArcCenterPoint = CGPointMake(topLeftPoint.x, rightArcCenterPoint.y);
	
	CGPathMoveToPoint(path, NULL, topLeftPoint.x, topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, topRightPoint.x, topRightPoint.y);
	CGPathAddArc(path, NULL, rightArcCenterPoint.x, rightArcCenterPoint.y, radius, radians(270.0), radians(90.0), NO);
	//CGPathMoveToPoint(path, NULL, bottomRightPoint.x, bottomRightPoint.y);
	CGPathAddLineToPoint(path, NULL, bottomLeftPoint.x, bottomLeftPoint.y);
	CGPathAddArc(path, NULL, leftArcCenterPoint.x, leftArcCenterPoint.y, radius, radians(90.0), radians(270.0), NO);
	
	return path;
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, 
						CGColorRef  endColor) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
	
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
														(CFArrayRef) colors, locations);
	
    // More coming... 
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}
