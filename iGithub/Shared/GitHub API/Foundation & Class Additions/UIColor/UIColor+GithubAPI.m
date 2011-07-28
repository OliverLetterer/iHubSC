//
//  UIColor+GithubAPI.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIColor+GithubAPI.h"


@implementation UIColor (GHAPIColorParsing)

+ (UIColor *)colorFromAPIHexColorString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned int baseColor = 0;
    [scanner scanHexInt:&baseColor];
    
    CGFloat red   = ((baseColor & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((baseColor & 0x00FF00) >>  8) / 255.0f;
    CGFloat blue  = ((baseColor & 0x0000FF) >>  1) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

@end
