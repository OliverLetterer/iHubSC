//
//  GHAuthenticationManager.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIAuthenticationManager.h"
#import "GithubAPI.h"
#import "SFHFKeychainUtils.h"

NSString *const GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification = @"GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification";
NSString *const kGHAPIKeychainService = @"de.olettere.iGithub";

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
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification object:nil] ];
}

#pragma mark - Memory management


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
	return [self sharedInstance];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

@end





#pragma mark - GHAPIUserV3 additions

@implementation GHAPIUserV3 (GHAPIAuthenticationManagerAdditions)

- (NSString *)password {
    return [SFHFKeychainUtils getPasswordForUsername:self.login 
                                      andServiceName:kGHAPIKeychainService 
                                               error:NULL];;
}

- (void)setPassword:(NSString *)password {
    [SFHFKeychainUtils storeUsername:self.login 
                         andPassword:password 
                      forServiceName:kGHAPIKeychainService 
                      updateExisting:YES 
                               error:NULL];
}

@end
