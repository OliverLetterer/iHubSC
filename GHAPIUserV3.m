//
//  GHAPIUserV3.m
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIUserV3.h"
#import "GithubAPI.h"

@implementation GHAPIUserV3

@synthesize login=_login, ID=_ID, gravatarID=_gravatarID, URL=_URL, name=_name, company=_company, blog=_blog, location=_location, EMail=_EMail, hireable=_hireable, bio=_bio, publicRepos=_publicRepos, publicGists=_publicGists, followers=_followers, following=_following, htmlURL=_htmlURL, createdAt=_createdAt, type=_type, totalPrivateRepos=_totalPrivateRepos, ownedPrivateRepos=_ownedPrivateRepos, privateGists=_privateGists, diskUsage=_diskUsage, collaborators=_collaborators, plan=_plan;

#pragma mark - setters and getters

- (BOOL)hasEMail {
    return self.EMail != nil;
}

- (BOOL)hasLocation {
    return self.location != nil;
}

- (BOOL)hasCompany {
    return self.company != nil;
}

- (BOOL)hasBlog {
    return self.blog != nil;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.login = [rawDictionay objectForKeyOrNilOnNullObject:@"login"];
        self.ID = [rawDictionay objectForKeyOrNilOnNullObject:@"id"];
        self.gravatarID = [[rawDictionay objectForKeyOrNilOnNullObject:@"avatar_url"] gravarID];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.name = [rawDictionay objectForKeyOrNilOnNullObject:@"name"];
        self.company = [rawDictionay objectForKeyOrNilOnNullObject:@"company"];
        self.blog = [rawDictionay objectForKeyOrNilOnNullObject:@"blog"];
        self.location = [rawDictionay objectForKeyOrNilOnNullObject:@"location"];
        self.EMail = [rawDictionay objectForKeyOrNilOnNullObject:@"email"];
        self.hireable = [rawDictionay objectForKeyOrNilOnNullObject:@"hireable"];
        self.bio = [rawDictionay objectForKeyOrNilOnNullObject:@"bio"];
        self.publicRepos = [rawDictionay objectForKeyOrNilOnNullObject:@"public_repos"];
        self.publicGists = [rawDictionay objectForKeyOrNilOnNullObject:@"public_gists"];
        self.followers = [rawDictionay objectForKeyOrNilOnNullObject:@"followers"];
        self.following = [rawDictionay objectForKeyOrNilOnNullObject:@"following"];
        self.htmlURL = [rawDictionay objectForKeyOrNilOnNullObject:@"html_url"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.type = [rawDictionay objectForKeyOrNilOnNullObject:@"type"];
        self.totalPrivateRepos = [rawDictionay objectForKeyOrNilOnNullObject:@"total_private_repos"];
        self.ownedPrivateRepos = [rawDictionay objectForKeyOrNilOnNullObject:@"owned_private_repos"];
        self.privateGists = [rawDictionay objectForKeyOrNilOnNullObject:@"private_gists"];
        self.diskUsage = [rawDictionay objectForKeyOrNilOnNullObject:@"disk_usage"];
        self.collaborators = [rawDictionay objectForKeyOrNilOnNullObject:@"collaborators"];
        self.plan = [[[GHAPIUserPlanV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"plan"] ] autorelease];
    }
    return self;
}

#pragma mark - Downloading

+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler {
    
    // v3: GET /users/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@", 
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSDictionary *rawDictionary = object;
                                               handler([[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] , nil);
                                           }
                                       }];
}

+ (void)authenticatedUserWithUsername:(NSString *)username 
                             password:(NSString *)password 
                    completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler {
    
    // v3: GET /user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user" ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request addBasicAuthenticationHeaderWithUsername:username andPassword:password];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSDictionary *rawDictionary = object;
                                               handler([[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] , nil);
                                           }
                                       }];
    
}

+ (void)usersThatUsernameIsFollowing:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler {
    // v3: GET /users/:user/following
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/following",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               for (NSDictionary *rawDictionary in rawArray) {
                                                   [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                               }
                                               
                                               handler(finalArray, nil);
                                           }
                                       }];
}

+ (void)userThatAreFollowingUserNamed:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler {
    
    // v3: GET /users/:user/followers
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/followers",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               for (NSDictionary *rawDictionary in rawArray) {
                                                   [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                               }
                                               
                                               handler(finalArray, nil);
                                           }
                                       }];
}

+ (void)isFollowingUserNamed:(NSString *)username completionHandler:(void(^)(BOOL following, NSError *error))handler {
    
    // v3: GET /user/following/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/following/%@",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if ([request responseStatusCode] == 404) {
                                               handler(NO, nil);
                                           } else if (error) {
                                               handler(NO, error);
                                           } else {
                                               handler([request responseStatusCode] == 204, nil);
                                           }
                                       }];
}

+ (void)followUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler {
    // v3: PUT /user/following/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/following/%@",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)unfollowUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler {
    // v3: DELETE /user/following/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/following/%@",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
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
                                                   [finalArray addObject:[[[GHAPIGistV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                               }
                                               
                                               NSString *linkHeader = [[request responseHeaders] objectForKey:@"Link"];
                                               
                                               handler(finalArray, linkHeader.nextPage, nil);
                                           }
                                           
                                       }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_login release];
    [_ID release];
    [_gravatarID release];
    [_URL release];
    [_name release];
    [_company release];
    [_blog release];
    [_location release];
    [_EMail release];
    [_hireable release];
    [_bio release];
    [_publicRepos release];
    [_publicGists release];
    [_followers release];
    [_following release];
    [_htmlURL release];
    [_createdAt release];
    [_type release];
    [_totalPrivateRepos release];
    [_ownedPrivateRepos release];
    [_privateGists release];
    [_diskUsage release];
    [_collaborators release];
    [_plan release];
    
    [super dealloc];
}

@end
