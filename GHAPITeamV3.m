//
//  GHAPITeamV3.m
//  iGithub
//
//  Created by Oliver Letterer on 12.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPITeamV3.h"
#import "GithubAPI.h"

NSString *const GHAPITeamV3PermissionPull = @"pull";
NSString *const GHAPITeamV3PermissionPush = @"push";
NSString *const GHAPITeamV3PermissionAdmin = @"admin";

@implementation GHAPITeamV3

@synthesize URL = _URL, name = _name, ID = _ID, permission = _permission, membersCount = _membersCount, reposCount = _reposCount;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.permission = [rawDictionary objectForKeyOrNilOnNullObject:@"permission"];
        self.membersCount = [rawDictionary objectForKeyOrNilOnNullObject:@"members_count"];
        self.reposCount = [rawDictionary objectForKeyOrNilOnNullObject:@"repos_count"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_name release];
    [_ID release];
    [_permission release];
    [_membersCount release];
    [_reposCount release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_permission forKey:@"permission"];
    [encoder encodeObject:_membersCount forKey:@"membersCount"];
    [encoder encodeObject:_reposCount forKey:@"reposCount"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _permission = [[decoder decodeObjectForKey:@"permission"] retain];
        _membersCount = [[decoder decodeObjectForKey:@"membersCount"] retain];
        _reposCount = [[decoder decodeObjectForKey:@"reposCount"] retain];
    }
    return self;
}

#pragma mark - API calls

+ (void)teamByID:(NSNumber *)teamID completionHandler:(void (^)(GHAPITeamV3 *team, NSError *error))handler {
    // v3: GET /teams/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@",
                                       teamID ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHAPITeamV3 alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                       }];
}

+ (void)deleteTeamWithID:(NSNumber *)teamID completionHandler:(GHAPIErrorHandler)handler {
    // v3: DELETE /teams/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@",
                                       teamID ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)membersOfTeamByID:(NSNumber *)teamID page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /teams/:id/members
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/members",
                                       teamID ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:obj] autorelease] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)repositoriesOfTeamByID:(NSNumber *)teamID page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /teams/:id/repos
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/repos",
                                       teamID ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPIRepositoryV3 alloc] initWithRawDictionary:obj] autorelease] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)teamByID:(NSNumber *)teamID deleteUserNamed:(NSString *)username completionHandler:(GHAPIErrorHandler)handler {
    // v3: DELETE /teams/:id/members/:user
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/members/%@",
                                       teamID,
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)teamByID:(NSNumber *)teamID deleteRepositoryNamed:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler {
    // v3: DELETE /teams/:id/repos/:repo
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/repos/%@",
                                       teamID,
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

@end
