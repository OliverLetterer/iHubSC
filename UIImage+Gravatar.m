//
//  UIImage+Gravatar.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIImage+Gravatar.h"
#import "GithubAPI.h"

@implementation UIImage (GHGravatar)

+ (void)imageFromGravatarID:(NSString *)gravatarID withCompletionHandler:(void(^)(UIImage *image, NSError *error))handler {
    UIImage *myImage = [GHGravatarImageCache cachedGravatarImageFromGravatarID:gravatarID];
    
    if (!myImage) {
        dispatch_async(GHAPIBackgroundQueue(), ^(void) {
            NSError *myError = nil;
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=200", gravatarID]];
            
            NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageURL] 
                                                      returningResponse:NULL 
                                                                  error:&myError];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (myError) {
                    handler(nil, myError);
                } else {
                    UIImage *newImage = [[[UIImage alloc] initWithData:imageData] autorelease];
                    [GHGravatarImageCache cacheGravatarImage:newImage forGravatarID:gravatarID];
                    handler(newImage, nil);
                }
            });
        });
    } else {
        handler(myImage, nil);
    }
}


- (void)imageWithCompletionHandler:(void (^)(UIImage *, NSError *))handler {
    
}
@end
