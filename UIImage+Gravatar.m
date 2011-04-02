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

@implementation UIImage (GHGravatar)

+ (void)imageFromGravatarID:(NSString *)gravatarID 
      withCompletionHandler:(void(^)(UIImage *image, NSError *error, BOOL didDownload))handler {
    UIImage *myImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (!myImage) {
        dispatch_async([GHGravatarBackgroundQueue sharedInstance].backgroundQueue, ^(void) {
            NSError *myError = nil;
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=200", gravatarID]];
            
            NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageURL] 
                                                      returningResponse:NULL 
                                                                  error:&myError];
            UIImage *theImage = [[[UIImage alloc] initWithData:imageData] autorelease];
            
            CGSize imageSize = CGSizeMake(64.0 * [UIScreen mainScreen].scale, 64.0 * [UIScreen mainScreen].scale);
            
            [theImage resizedImage:imageSize interpolationQuality:kCGInterpolationHigh];
            [GHGravatarImageCache cacheGravatarImage:theImage forGravatarID:gravatarID];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (myError) {
                    handler(nil, myError, NO);
                } else {
                    handler(theImage, nil, YES);
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
