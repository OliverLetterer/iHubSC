//
//  GHAPIImageQueueV3.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIImageCacheV3.h"

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

@end





#pragma mark - Singleton implementation

static GHAPIImageCacheV3 *_instance = nil;

@implementation GHAPIImageCacheV3 (Singleton)

+ (GHAPIImageQueueV3 *)sharedInstance {
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
