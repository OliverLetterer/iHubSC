//
//  GHUser.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUser.h"
#import "GithubAPI.h"
#import "ASIHTTPRequest.h"

@implementation GHUser

@synthesize createdAt=_createdAt, gravatarID=_gravatarID, login=_login, type=_type, image=_image;
@synthesize followersCount=_followersCount, followingCount=_followingCount, ID=_ID, publicGistCount=_publicGistCount, publicRepoCount=_publicRepoCount;

@synthesize privateRepoCount=_privateRepoCount, collaborators=_collaborators, diskUsage=_diskUsage, ownedPrivateRepoCount=_ownedPrivateRepoCount, privateGistCount=_privateGistCount, planCollaborators=_planCollaborators, planSpace=_planSpace, planPrivateRepos=_planPrivateRepos;
@synthesize planName=_planName, password=_password;

- (BOOL)isAuthenticated {
    return self.password != nil && self.planName != nil;
}

#pragma mark - Initialization

+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHUser *user, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@", [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *userData = [request responseData];
        NSString *userString = [[[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *userDictionary = nil;
                userDictionary = [userString objectFromJSONString];
                if ([userDictionary objectForKey:@"error"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:[userDictionary objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
                    handler(nil, [NSError errorWithDomain:@"unkownError" code:0 userInfo:userInfo]);
                } else {
                    handler([GHUser userFromRawUserDictionary:userDictionary], nil);
                }
            }
        });
    });
}

+ (void)authenticatedUserWithUsername:(NSString *)username 
                             password:(NSString *)password 
                    completionHandler:(void(^)(GHUser *user, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL];
        [request addBasicAuthenticationHeaderWithUsername:username andPassword:password];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *userData = [request responseData];
        NSString *userString = [[[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *userDictionary = [userString objectFromJSONString];
                if (![[userDictionary objectForKey:@"user"] objectForKey:@"plan"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:NSLocalizedString(@"Invalid Username or Password", @"") forKey:NSLocalizedDescriptionKey];
                    handler(nil, [NSError errorWithDomain:@"unkownError" code:0 userInfo:userInfo]);
                } else if ([userDictionary objectForKey:@"error"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:[userDictionary objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
                    handler(nil, [NSError errorWithDomain:@"unkownError" code:0 userInfo:userInfo]);
                } else {
                    GHUser *user = [GHUser userFromRawUserDictionary:userDictionary];
                    user.password = password;
                    handler(user, nil);
                }
            }
        });
    });
}

+ (GHUser *)userFromRawUserDictionary:(NSDictionary *)rawDictionary {
    return [[[GHUser alloc] initWithRawUserDictionary:rawDictionary] autorelease];
}

- (id)initWithRawUserDictionary:(NSDictionary *)rawDictionary {
    NSDictionary *userDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
    if ((self = [self initWithRawDictionary:userDictionary])) {
        // setup here
    }
    return self;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // setup here
        self.createdAt = [rawDictionary objectForKey:@"created_at"];
        self.gravatarID = [rawDictionary objectForKey:@"gravatar_id"];
        self.login = [rawDictionary objectForKey:@"login"];
        self.type = [rawDictionary objectForKey:@"type"];
        
        self.followersCount = [[rawDictionary objectForKey:@"followers_count"] intValue];
        self.followingCount = [[rawDictionary objectForKey:@"following_count"] intValue];
        self.ID = [[rawDictionary objectForKey:@"id"] intValue];
        self.publicGistCount = [[rawDictionary objectForKey:@"public_gist_count"] intValue];
        self.publicRepoCount = [[rawDictionary objectForKey:@"public_repo_count"] intValue];
        
        // private github stuff
        self.privateRepoCount = [[rawDictionary objectForKey:@"total_private_repo_count"] intValue];
        self.collaborators = [[rawDictionary objectForKey:@"collaborators"] intValue];
        self.diskUsage = [[rawDictionary objectForKey:@"disk_usage"] intValue];
        self.ownedPrivateRepoCount = [[rawDictionary objectForKey:@"owned_private_repo_count"] intValue];
        self.privateGistCount = [[rawDictionary objectForKey:@"private_gist_count"] intValue];
        
        self.planName = [[rawDictionary objectForKey:@"plan"] objectForKey:@"name"];
        self.planCollaborators = [[[rawDictionary objectForKey:@"plan"] objectForKey:@"collaborators"] intValue];
        self.planSpace = [[[rawDictionary objectForKey:@"plan"] objectForKey:@"space"] intValue];
        self.planPrivateRepos = [[[rawDictionary objectForKey:@"plan"] objectForKey:@"private_repos"] intValue];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_createdAt release];
    [_gravatarID release];
    [_login release];
    [_type release];
    [_image release];
    [_planName release];
    [_password release];
    [super dealloc];
}

@end
