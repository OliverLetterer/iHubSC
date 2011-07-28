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
NSString *const kGHAPIAuthenticationManagerAuthenticatedUserFileName = @"kGHAPIAuthenticationManagerAuthenticatedUser.plist";

@interface GHAPIAuthenticationManager () {
@private
    
}

@property (nonatomic, readonly) NSURL *saveURL;

- (void)_saveUserState;
- (void)_loadUserState;

@end

@implementation GHAPIAuthenticationManager
@synthesize username=_username, password=_password;
@synthesize authenticatedUser=_authenticatedUser;

#pragma mark - Setters and getters

- (NSArray *)usersArray {
    return [_usersArray copy];
}

- (void)setAuthenticatedUser:(GHAPIUserV3 *)authenticatedUser {
    if (![_usersArray containsObject:authenticatedUser]) {
        DLog(@"_usersArray (%@) does not contain authenticatedUser(%@)", _usersArray, authenticatedUser);
        return;
    }
    
    if (authenticatedUser != _authenticatedUser) {
        _authenticatedUser = authenticatedUser;
        
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
    NSURL *userURL = [self.saveURL URLByAppendingPathComponent:kGHAPIAuthenticationManagerAuthenticatedUserFileName];
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:_usersArray];
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_authenticatedUser];
    
    [arrayData writeToURL:arrayURL options:NSDataWritingFileProtectionNone error:nil];
    [userData writeToURL:userURL options:NSDataWritingFileProtectionNone error:nil];
}

- (void)_loadUserState {
    NSURL *arrayURL = [self.saveURL URLByAppendingPathComponent:kGHAPIAuthenticationManagerUsersArrayFileName];
    NSURL *userURL = [self.saveURL URLByAppendingPathComponent:kGHAPIAuthenticationManagerAuthenticatedUserFileName];
    
    NSData *arrayData = [NSData dataWithContentsOfURL:arrayURL];
    NSData *userData = [NSData dataWithContentsOfURL:userURL];
    
    _usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    _authenticatedUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
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

- (void)saveAuthenticatedUserWithName:(NSString *)username password:(NSString *)password {
    self.username = username;
    self.password = password;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification object:nil] ];
}

- (void)addAuthenticatedUser:(GHAPIUserV3 *)user password:(NSString *)password {
    user.password = password;
    [_usersArray addObject:user];
    self.authenticatedUser = user;
}

- (void)removeAuthenticatedUser:(GHAPIUserV3 *)user {
    [_usersArray removeObject:user];
    GHAPIUserV3 *newUser = nil;
    if (_usersArray.count > 0) {
        newUser = [_usersArray objectAtIndex:0];
    }
    self.authenticatedUser = nil;
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
