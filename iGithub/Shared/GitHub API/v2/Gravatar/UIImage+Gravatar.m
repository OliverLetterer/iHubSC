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

@implementation UIImage (GHGravatar)

+ (void)imageFromGravatarID:(NSString *)gravatarID 
      withCompletionHandler:(void(^)(UIImage *image, NSError *error, BOOL didDownload))handler {
    
    UIImage *myImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (!myImage) {
        dispatch_async([GHGravatarBackgroundQueue sharedInstance].backgroundQueue, ^(void) {
            UIImage *myImage = [UIImage cachedImageFromGravatarID:gravatarID];
            if (myImage) {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    handler(myImage, nil, NO);
                });
                return;
            }
            
            NSError *myError = nil;
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=200", gravatarID]];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageURL];
            [request startSynchronous];
            
            myError = [request error];
            
            NSData *imageData = [request responseData];
            
            UIImage *theImage = [[UIImage alloc] initWithData:imageData];
            
            if (theImage) {
                CGSize imageSize = CGSizeMake(56.0 * [UIScreen mainScreen].scale, 56.0 * [UIScreen mainScreen].scale);
                
                theImage = [theImage resizedImageToSize:imageSize];
                [GHGravatarImageCache cacheGravatarImage:theImage forGravatarID:gravatarID];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (myError) {
                    handler(nil, myError, NO);
                } else {
                    if (theImage) {
                        handler(theImage, nil, YES);
                    } else {
                        handler([UIImage imageNamed:@"DefaultUserImage.png"], nil, NO);
                    }
                }
            });
        });
    } else {
        handler(myImage, nil, NO);
    }
}

+ (UIImage *)cachedImageFromGravatarID:(NSString *)gravatarID {
    return [GHGravatarImageCache cachedGravatarImageFromGravatarID:gravatarID];
}

@end
