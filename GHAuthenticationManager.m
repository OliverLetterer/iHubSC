//
//  GHAuthenticationManager.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAuthenticationManager.h"

@implementation GHAuthenticationManager

@synthesize username=_username, password=_password;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    [_password release];
    [super dealloc];
}

@end





#pragma mark - Singleton implementation

static GHAuthenticationManager *_instance = nil;

@implementation GHAuthenticationManager (Singleton)

+ (GHAuthenticationManager *)sharedInstance {
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
