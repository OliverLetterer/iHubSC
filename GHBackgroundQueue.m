//
//  GHBackgroundQueue.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHBackgroundQueue.h"

dispatch_queue_t GHAPIBackgroundQueue() {
    return [GHBackgroundQueue sharedInstance].backgroundQueue;
}

@implementation GHBackgroundQueue

- (dispatch_queue_t)backgroundQueue {
    if (!_backgroundQueue) {
        _backgroundQueue = dispatch_queue_create("de.olettere.GHAPI.backgroundQueue", NULL);
    }
    return _backgroundQueue;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

@end





#pragma mark - Singleton implementation

static GHBackgroundQueue *_instance = nil;

@implementation GHBackgroundQueue (Singleton)

+ (GHBackgroundQueue *)sharedInstance {
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
