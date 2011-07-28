//
//  UIImage+GHTabBar.h
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GHTabBar)

- (UIImage *)tabBarBackgroundImageWithSize:(CGSize)targetSize backgroundImage:(UIImage*)backgroundImage;
- (UIImage *)blackFilledImageWithWhiteBackgroundUsing:(UIImage*)startImage;

- (UIImage *)tabBarStyledImageWithSize:(CGSize)targetSize style:(BOOL)selected;

@end
