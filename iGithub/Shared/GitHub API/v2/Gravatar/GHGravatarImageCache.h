//
//  GHGravatarImageCache.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *GHGravatarImageCacheDirectory();

@interface GHGravatarImageCache : NSObject {
    
}

+ (void)cacheGravatarImage:(UIImage *)gravatarImage forGravatarID:(NSString *)gravatarID;
+ (UIImage *)cachedGravatarImageFromGravatarID:(NSString *)gravatarID;

@end
