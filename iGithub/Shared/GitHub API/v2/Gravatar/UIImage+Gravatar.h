//
//  UIImage+Gravatar.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (GHGravatar)

+ (void)imageFromGravatarID:(NSString *)gravatarID 
      withCompletionHandler:(void(^)(UIImage *image))handler;

+ (UIImage *)cachedImageFromGravatarID:(NSString *)gravatarID;

@end
