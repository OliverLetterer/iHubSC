//
//  UIColor+GithubAPI.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (GHAPIColorParsing)

+ (UIColor *)colorFromAPIHexColorString:(NSString *)hexString;

@end
