//
//  UIImage+Gravatar.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIImage+Gravatar.h"
#import "GithubAPI.h"
#import "UIImage+Resize.h"
#import "ASIHTTPRequest.h"
#import "UIImage+GHAPIImageCacheV3.h"

@implementation UIImage (GHGravatar)

+ (void)imageFromGravatarID:(NSString *)gravatarID 
      withCompletionHandler:(void(^)(UIImage *image))handler {
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=200", gravatarID]];
    NSString *URLString = [imageURL absoluteString];
    
    [UIImage imageFromAvatarURLString:URLString withCompletionHandler:handler];
    
}

+ (UIImage *)cachedImageFromGravatarID:(NSString *)gravatarID {
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=200", gravatarID]];
    NSString *URLString = [imageURL absoluteString];
    
    return [UIImage cachedImageFromAvatarURLString:URLString];
}

@end
