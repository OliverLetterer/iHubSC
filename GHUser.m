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

@synthesize EMail=_EMail, location=_location, company=_company, blog=_blog;

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
                if ([userDictionary objectForKeyOrNilOnNullObject:@"error"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:[userDictionary objectForKeyOrNilOnNullObject:@"error"] forKey:NSLocalizedDescriptionKey];
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
                if (![[userDictionary objectForKeyOrNilOnNullObject:@"user"] objectForKeyOrNilOnNullObject:@"plan"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:NSLocalizedString(@"Invalid Username or Password", @"") forKey:NSLocalizedDescriptionKey];
                    handler(nil, [NSError errorWithDomain:@"unkownError" code:0 userInfo:userInfo]);
                } else if ([userDictionary objectForKeyOrNilOnNullObject:@"error"]) {
                    // handle error
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:[userDictionary objectForKeyOrNilOnNullObject:@"error"] forKey:NSLocalizedDescriptionKey];
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

+ (void)usersFollowingUserNamed:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /user/show/:user/following
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@/following",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSString *jsonString = [request responseString];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [jsonString objectFromJSONString];
                handler([dictionary objectForKey:@"users"], nil);            }
        });
    });
}

+ (void)usersFollowedByUserNamed:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /user/show/:user/followers
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@/followers",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSString *jsonString = [request responseString];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [jsonString objectFromJSONString];
                handler([dictionary objectForKey:@"users"], nil);
            }
        });
    });
}

+ (void)followUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /user/follow/:user [POST]
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/follow/%@",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setPostValue:username forKey:@"name"];
        [request startSynchronous];
        
        myError = [request error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            handler(myError);
        });
    });
}

+ (void)unfollowUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /user/unfollow/:user [POST]
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/unfollow/%@",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        
        [request setPostValue:username forKey:@"name"];
        
        [request startSynchronous];
        
        myError = [request error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            handler(myError);
        });
    });
}

+ (void)searchUsersWithSearchString:(NSString *)searchString completionHandler:(void (^)(NSArray *, NSError *))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/xml/user/search/chacon
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/search/%@",
                                           [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [[request responseString] objectFromJSONString];
                
                NSArray *allUsers = [dictionary objectForKeyOrNilOnNullObject:@"users"];
                NSMutableArray *users = [NSMutableArray arrayWithCapacity:[allUsers count] ];
                
                for (NSDictionary *rawUser in allUsers) {
                    [users addObject:[[[GHUser alloc] initWithRawDictionary:rawUser] autorelease] ];
                }
                
                handler(users, nil);
            }
        });
    });
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
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        
        self.followersCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"followers_count"] intValue];
        self.followingCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"following_count"] intValue];
        self.ID = [[rawDictionary objectForKeyOrNilOnNullObject:@"id"] intValue];
        self.publicGistCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"public_gist_count"] intValue];
        self.publicRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"public_repo_count"] intValue];
        
        // private github stuff
        self.privateRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"total_private_repo_count"] intValue];
        self.collaborators = [[rawDictionary objectForKeyOrNilOnNullObject:@"collaborators"] intValue];
        self.diskUsage = [[rawDictionary objectForKeyOrNilOnNullObject:@"disk_usage"] intValue];
        self.ownedPrivateRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"owned_private_repo_count"] intValue];
        self.privateGistCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"private_gist_count"] intValue];
        
        self.planName = [[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"name"];
        self.planCollaborators = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"collaborators"] intValue];
        self.planSpace = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"space"] intValue];
        self.planPrivateRepos = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"private_repos"] intValue];
        
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.company = [rawDictionary objectForKeyOrNilOnNullObject:@"company"];
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        
        // API v3
        if (!self.gravatarID) {
            NSString *gravatarURL = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_url"];
            self.gravatarID = gravatarURL.gravarID;
        }
    }
    return self;
}

+ (void)gistsOfUser:(NSString *)username page:(NSInteger)page completionHandler:(void (^)(NSArray *gists, NSInteger nextPage, NSError *error))handler {
    
    // v3: GET /users/:user/gists
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/gists?page=%d&per_page=100", 
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, 0, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               for (NSDictionary *rawDictionary in rawArray) {
                                                   [finalArray addObject:[[[GHGist alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                               }
                                               
                                               NSString *linkHeader = [[request responseHeaders] objectForKey:@"Link"];
                                               
                                               handler(finalArray, linkHeader.nextPage, nil);
                                           }
                                           
    }];
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
    
    [_location release];
    [_EMail release];
    [_company release];
    [_blog release];
    
    [_image release];
    [super dealloc];
}

@end
