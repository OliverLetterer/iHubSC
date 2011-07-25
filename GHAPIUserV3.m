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

@synthesize login=_login, ID=_ID, avatarURL=_avatarURL, gravatarID=_gravatarID, URL=_URL, name=_name, company=_company, blog=_blog, location=_location, EMail=_EMail, hireable=_hireable, bio=_bio, publicRepos=_publicRepos, publicGists=_publicGists, followers=_followers, following=_following, htmlURL=_htmlURL, createdAt=_createdAt, type=_type, totalPrivateRepos=_totalPrivateRepos, ownedPrivateRepos=_ownedPrivateRepos, privateGists=_privateGists, diskUsage=_diskUsage, collaborators=_collaborators, plan=_plan;

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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.avatarURL = [rawDictionary objectForKeyOrNilOnNullObject:@"avatar_url"];
        self.gravatarID = [[rawDictionary objectForKeyOrNilOnNullObject:@"avatar_url"] gravarID];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.company = [rawDictionary objectForKeyOrNilOnNullObject:@"company"];
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
        self.hireable = [rawDictionary objectForKeyOrNilOnNullObject:@"hireable"];
        self.bio = [rawDictionary objectForKeyOrNilOnNullObject:@"bio"];
        self.publicRepos = [rawDictionary objectForKeyOrNilOnNullObject:@"public_repos"];
        self.publicGists = [rawDictionary objectForKeyOrNilOnNullObject:@"public_gists"];
        self.followers = [rawDictionary objectForKeyOrNilOnNullObject:@"followers"];
        self.following = [rawDictionary objectForKeyOrNilOnNullObject:@"following"];
        self.htmlURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        self.totalPrivateRepos = [rawDictionary objectForKeyOrNilOnNullObject:@"total_private_repos"];
        self.ownedPrivateRepos = [rawDictionary objectForKeyOrNilOnNullObject:@"owned_private_repos"];
        self.privateGists = [rawDictionary objectForKeyOrNilOnNullObject:@"private_gists"];
        self.diskUsage = [rawDictionary objectForKeyOrNilOnNullObject:@"disk_usage"];
        self.collaborators = [rawDictionary objectForKeyOrNilOnNullObject:@"collaborators"];
        self.plan = [[[GHAPIUserPlanV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] ] autorelease];
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_login forKey:@"login"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_avatarURL forKey:@"avatarURL"];
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_company forKey:@"company"];
    [encoder encodeObject:_blog forKey:@"blog"];
    [encoder encodeObject:_location forKey:@"location"];
    [encoder encodeObject:_EMail forKey:@"eMail"];
    [encoder encodeObject:_hireable forKey:@"hireable"];
    [encoder encodeObject:_bio forKey:@"bio"];
    [encoder encodeObject:_publicRepos forKey:@"publicRepos"];
    [encoder encodeObject:_publicGists forKey:@"publicGists"];
    [encoder encodeObject:_followers forKey:@"followers"];
    [encoder encodeObject:_following forKey:@"following"];
    [encoder encodeObject:_htmlURL forKey:@"htmlURL"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_type forKey:@"type"];
    [encoder encodeObject:_totalPrivateRepos forKey:@"totalPrivateRepos"];
    [encoder encodeObject:_ownedPrivateRepos forKey:@"ownedPrivateRepos"];
    [encoder encodeObject:_privateGists forKey:@"privateGists"];
    [encoder encodeObject:_diskUsage forKey:@"diskUsage"];
    [encoder encodeObject:_collaborators forKey:@"collaborators"];
    [encoder encodeObject:_plan forKey:@"plan"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _login = [[decoder decodeObjectForKey:@"login"] retain];
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _avatarURL = [[decoder decodeObjectForKey:@"avatarURL"] retain];
        _gravatarID = [[decoder decodeObjectForKey:@"gravatarID"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _company = [[decoder decodeObjectForKey:@"company"] retain];
        _blog = [[decoder decodeObjectForKey:@"blog"] retain];
        _location = [[decoder decodeObjectForKey:@"location"] retain];
        _EMail = [[decoder decodeObjectForKey:@"eMail"] retain];
        _hireable = [[decoder decodeObjectForKey:@"hireable"] retain];
        _bio = [[decoder decodeObjectForKey:@"bio"] retain];
        _publicRepos = [[decoder decodeObjectForKey:@"publicRepos"] retain];
        _publicGists = [[decoder decodeObjectForKey:@"publicGists"] retain];
        _followers = [[decoder decodeObjectForKey:@"followers"] retain];
        _following = [[decoder decodeObjectForKey:@"following"] retain];
        _htmlURL = [[decoder decodeObjectForKey:@"htmlURL"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _type = [[decoder decodeObjectForKey:@"type"] retain];
        _totalPrivateRepos = [[decoder decodeObjectForKey:@"totalPrivateRepos"] retain];
        _ownedPrivateRepos = [[decoder decodeObjectForKey:@"ownedPrivateRepos"] retain];
        _privateGists = [[decoder decodeObjectForKey:@"privateGists"] retain];
        _diskUsage = [[decoder decodeObjectForKey:@"diskUsage"] retain];
        _collaborators = [[decoder decodeObjectForKey:@"collaborators"] retain];
        _plan = [[decoder decodeObjectForKey:@"plan"] retain];
    }
    return self;
}

#pragma mark - Downloading

+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler {
    
    // v3: GET /users/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@", 
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHAPIUserV3 alloc] initWithRawDictionary:object] autorelease] , nil);
                                           }
                                       }];
}

+ (void)authenticatedUserWithUsername:(NSString *)username 
                             password:(NSString *)password 
                    completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler {
    
    // v3: GET /user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user" ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request addBasicAuthenticationHeaderWithUsername:username andPassword:password];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHAPIUserV3 alloc] initWithRawDictionary:object] autorelease] , nil);
                                           }
                                       }];
    
}

+ (void)usersThatUsernameIsFollowing:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /users/:user/following
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/following",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                    page:page 
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)usersThatAreFollowingUserNamed:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /users/:user/followers
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/followers",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                    page:page 
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)isFollowingUserNamed:(NSString *)username completionHandler:(void(^)(BOOL following, NSError *error))handler {
    
    // v3: GET /user/following/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/following/%@",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)gistsOfUser:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    
    // v3: GET /users/:user/gists
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/gists", 
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                page:page
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, 0, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIGistV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_login release];
    [_ID release];
    [_avatarURL release];
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
