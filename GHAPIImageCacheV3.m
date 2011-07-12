//
//  GHAPIImageCacheV3.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIImageCacheV3.h"
#import "GithubAPI.h"

NSString *GHAPIGravatarImageCacheDirectoryV3() {
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

@implementation GHAPIImageCacheV3
@synthesize imagesCache=_imagesCache;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        self.imagesCache = [[[NSCache alloc] init] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_imagesCache release];
    
    [super dealloc];
}

#pragma mark - Instance methods

- (void)cacheImage:(UIImage *)image forURL:(NSString *)imageURLString {
    imageURLString = imageURLString.stringFromMD5Hash;
    if (!imageURLString) {
        return;
    }
    NSString *imagesCacheDirectory = GHAPIGravatarImageCacheDirectoryV3();
    
    NSData *pngData = UIImagePNGRepresentation(image);
    [pngData writeToFile:[imagesCacheDirectory stringByAppendingPathComponent:[imageURLString stringByAppendingString:@".png"]] 
              atomically:YES];
    [self.imagesCache setObject:image forKey:imageURLString];
}

- (UIImage *)cachedImageFromURL:(NSString *)imageURLString {
    imageURLString = imageURLString.stringFromMD5Hash;
    if (!imageURLString) {
        return [UIImage imageNamed:@"DefaultUserImage.png"];
    }
    
    
    UIImage *inMemoryCachedImage = [self.imagesCache objectForKey:imageURLString];
    if (inMemoryCachedImage) {
        return inMemoryCachedImage;
    }
    
    NSString *imagesCacheDirectory = GHAPIGravatarImageCacheDirectoryV3();
    NSString *filePath = [imagesCacheDirectory stringByAppendingPathComponent:[imageURLString stringByAppendingString:@".png"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL]) {
        return nil;
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    NSDate *lastModificationDate = [attributes objectForKey:NSFileModificationDate];
    
    if (fabs([lastModificationDate timeIntervalSinceNow]) > 259200) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        return nil;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    [self.imagesCache setObject:image forKey:imageURLString];
    return image;
}

@end





#pragma mark - Singleton implementation

static GHAPIImageCacheV3 *_instance = nil;

@implementation GHAPIImageCacheV3 (Singleton)

+ (GHAPIImageCacheV3 *)sharedInstance {
	@synchronized(self) {
		
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
	return [[self sharedInstance] retain];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {	
    return self;	
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
