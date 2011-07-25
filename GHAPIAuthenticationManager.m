//
//  GHAuthenticationManager.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIAuthenticationManager.h"

NSString *const GHAPIAuthenticationManagerDidAuthenticateNewUserNotification = @"GHAuthenticationManagerDidAuthenticateNewUser";

@implementation GHAPIAuthenticationManager

@synthesize username=_username, password=_password;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Instance methods

- (void)saveAuthenticatedUserWithName:(NSString *)username password:(NSString *)password {
    self.username = username;
    self.password = password;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:GHAPIAuthenticationManagerDidAuthenticateNewUserNotification object:nil] ];
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    [_password release];
    [super dealloc];
}

@end





#pragma mark - Singleton implementation

static GHAPIAuthenticationManager *_instance = nil;

@implementation GHAPIAuthenticationManager (Singleton)

+ (GHAPIAuthenticationManager *)sharedInstance {
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
