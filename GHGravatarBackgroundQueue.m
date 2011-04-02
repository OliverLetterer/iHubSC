//
//  GHGravatarBackgroundQueue.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGravatarBackgroundQueue.h"

@implementation GHGravatarBackgroundQueue

@synthesize imagesCache=_imagesCache;

- (dispatch_queue_t)backgroundQueue {
    if (!_backgroundQueue) {
        _backgroundQueue = dispatch_queue_create("de.olettere.GHAPI.gravatarBackgroundQueue", NULL);
    }
    return _backgroundQueue;
}

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

static GHGravatarBackgroundQueue *_instance = nil;

@implementation GHGravatarBackgroundQueue (Singleton)

+ (GHGravatarBackgroundQueue *)sharedInstance {
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
