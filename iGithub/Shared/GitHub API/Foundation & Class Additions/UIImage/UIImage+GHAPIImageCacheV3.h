//
//  UIImage+GHAPIImageCacheV3.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (GHAPIImageCacheV3)

+ (void)imageFromAvatarURLString:(NSString *)avatarURLString 
      withCompletionHandler:(void(^)(UIImage *image))handler;

+ (UIImage *)cachedImageFromAvatarURLString:(NSString *)avatarURLString;

@end
