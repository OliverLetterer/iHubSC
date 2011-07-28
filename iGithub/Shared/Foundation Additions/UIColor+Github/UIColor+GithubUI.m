//
//  UIColor+GithubUI.m
//  iGithub
//
//  Created by Oliver Letterer on 04.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIColor+GithubUI.h"


@implementation UIColor (GithubUI)

+ (UIColor *)defaultNavigationBarTintColor {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIColor darkGrayColor];
    }
    return [UIColor colorWithRed:22.0/255.0f green:70.0/255.0f blue:110.0/255.0f alpha:1.0];
}

@end
