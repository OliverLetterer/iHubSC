//
//  GHAPIImageCacheV3.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *GHAPIGravatarImageCacheDirectoryV3();

@interface GHAPIImageCacheV3 : NSObject {
@private
    NSCache *_imagesCache;
}

@property (nonatomic, retain)  NSCache *imagesCache;

- (void)cacheImage:(UIImage *)image forURL:(NSString *)imageURLString;
- (UIImage *)cachedImageFromURL:(NSString *)imageURLString;

@end


@interface GHAPIImageCacheV3 (Singleton)

+ (GHAPIImageCacheV3 *)sharedInstance;

@end
