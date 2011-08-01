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
NSString *const kGHAPIAuthenticationManagerUsersArrayFileName = @"GHAPIAuthenticationManagerUsersArray.plist";
NSString *const kGHAPIAuthenticationManagerLastAuthenticatedUserNumberKey = @"kGHAPIAuthenticationManagerLastAuthenticatedUserNumberKey";

@interface GHAPIAuthenticationManager () {
@private
    
}

@property (nonatomic, readonly) NSURL *saveURL;

- (void)_saveUserState;
- (void)_loadUserState;

@end

@implementation GHAPIAuthenticationManager
@synthesize authenticatedUser=_authenticatedUser;

#pragma mark - Setters and getters

- (NSArray *)usersArray {
    return [_usersArray copy];
}

- (void)setAuthenticatedUser:(GHAPIUserV3 *)authenticatedUser {
    if (![_usersArray containsObject:authenticatedUser] && authenticatedUser != nil) {
        DLog(@"_usersArray (%@) does not contain authenticatedUser(%@)", _usersArray, authenticatedUser);
        return;
    }
    
    if (authenticatedUser != _authenticatedUser) {
        _authenticatedUser = authenticatedUser;
        [self _saveUserState];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification object:nil] ];
    }
}

- (NSURL *)saveURL {
    NSURL *libraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *subDirectory = @"GHAPIAuthenticationManager";
    libraryURL = [libraryURL URLByAppendingPathComponent:subDirectory isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:libraryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return libraryURL;
}

#pragma mark - private

- (void)_saveUserState {
    NSURL *arrayURL = [self.saveURL URLByAppendingPathComponent:kGHAPIAuthenticationManagerUsersArrayFileName];
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:_usersArray];
    
    [arrayData writeToURL:arrayURL options:NSDataWritingFileProtectionNone error:nil];
    [[NSUserDefaults standardUserDefaults] setInteger:[_usersArray indexOfObject:_authenticatedUser] forKey:kGHAPIAuthenticationManagerLastAuthenticatedUserNumberKey];
}

- (void)_loadUserState {
    NSURL *arrayURL = [self.saveURL URLByAppendingPathComponent:kGHAPIAuthenticationManagerUsersArrayFileName];
    
    NSData *arrayData = [NSData dataWithContentsOfURL:arrayURL];
    
    _usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:kGHAPIAuthenticationManagerLastAuthenticatedUserNumberKey];
    @try {
        _authenticatedUser = [_usersArray objectAtIndex:index];
    }
    @catch (NSException *exception) { }
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        [self _loadUserState];
        if (!_usersArray) {
            _usersArray = [NSMutableArray array];
        }
    }
    return self;
}

#pragma mark - Instance methods

- (void)addAuthenticatedUser:(GHAPIUserV3 *)user password:(NSString *)password {
    user.password = password;
    [_usersArray addObject:user];
    self.authenticatedUser = user;
}

- (void)removeAuthenticatedUser:(GHAPIUserV3 *)user {
    [_usersArray removeObject:user];
    [self _saveUserState];
    
    if ([user isEqualToUser:self.authenticatedUser]) {
        GHAPIUserV3 *newUser = nil;
        if (_usersArray.count > 0) {
            newUser = [_usersArray objectAtIndex:0];
        }
        self.authenticatedUser = newUser;
    }
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
