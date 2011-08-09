//
//  UIBarButtonItem+GHEmpty.h
//  iGithub
//
//  Created by Oliver Letterer on 09.08.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (GHEmpty)

+ (UIBarButtonItem *)emptyBarButtonItemWithSizeOfTitle:(NSString *)title tintColor:(UIColor *)tintColor;
+ (UIBarButtonItem *)emptyBarButtonItemWithWidth:(CGFloat)width tintColor:(UIColor *)tintColor;

@end
