//
//  GHGravatarImageCache.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGravatarImageCache.h"
#import "GHGravatarBackgroundQueue.h"
#import <dispatch/dispatch.h>

NSString *GHGravatarImageCacheDirectory() {
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagesCacheDirectory = [cachesDirectory stringByAppendingPathComponent:@"GravatarImagesCache"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagesCacheDirectory isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesCacheDirectory 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:NULL];
    }
    
    return imagesCacheDirectory;
}

@implementation GHGravatarImageCache

#pragma mark - class methods

+ (void)cacheGravatarImage:(UIImage *)gravatarImage forGravatarID:(NSString *)gravatarID {
    if (!gravatarID) {
        return;
    }
    NSString *imagesCacheDirectory = GHGravatarImageCacheDirectory();
    
    NSData *pngData = UIImagePNGRepresentation(gravatarImage);
    [pngData writeToFile:[imagesCacheDirectory stringByAppendingPathComponent:[gravatarID stringByAppendingString:@".png"]] 
              atomically:YES];
    [[GHGravatarBackgroundQueue sharedInstance].imagesCache setObject:gravatarImage 
                                                               forKey:gravatarID];
}

+ (UIImage *)cachedGravatarImageFromGravatarID:(NSString *)gravatarID {
    
    if (!gravatarID) {
        return [UIImage imageNamed:@"DefaultUserImage.png"];
    }
    
    UIImage *inMemoryCachedImage = [[GHGravatarBackgroundQueue sharedInstance].imagesCache objectForKey:gravatarID];
    if (inMemoryCachedImage) {
        return inMemoryCachedImage;
    }
    
    NSString *imagesCacheDirectory = GHGravatarImageCacheDirectory();
    NSString *filePath = [imagesCacheDirectory stringByAppendingPathComponent:[gravatarID stringByAppendingString:@".png"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL]) {
        return nil;
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    NSDate *lastModificationDate = [attributes objectForKey:NSFileModificationDate];
    
    if (fabs([lastModificationDate timeIntervalSinceNow]) > 259200) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:filePath];
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        // Initialization code
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

@end
