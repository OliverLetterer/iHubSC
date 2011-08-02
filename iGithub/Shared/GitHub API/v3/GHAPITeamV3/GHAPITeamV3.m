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
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
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

#pragma mark - Keyed Archiving

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
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _name = [decoder decodeObjectForKey:@"name"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _permission = [decoder decodeObjectForKey:@"permission"];
        _membersCount = [decoder decodeObjectForKey:@"membersCount"];
        _reposCount = [decoder decodeObjectForKey:@"reposCount"];
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
                                               handler([[GHAPITeamV3 alloc] initWithRawDictionary:object], nil);
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIUserV3 alloc] initWithRawDictionary:obj] ];
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIRepositoryV3 alloc] initWithRawDictionary:obj] ];
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

+ (void)isUser:(NSString *)username memberInTeamByID:(NSNumber *)teamID completionHandler:(GHAPIStateHandler)handler {
    // v3: GET /teams/:id/members/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/members/%@",
                                       teamID,
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:nil 
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

+ (void)_dumpMembersOfTeamWithID:(NSNumber *)teamID inArray:(NSMutableArray *)membersArray page:(NSUInteger)page completionHandler:(GHAPIErrorHandler)handler {
    if (page == GHAPIPaginationNextPageNotFound) {
        handler(nil);
    } else {
        [GHAPITeamV3 membersOfTeamByID:teamID page:page 
                     completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                         if (error) {
                             handler(error);
                         } else {
                             [membersArray addObjectsFromArray:array];
                             [self _dumpMembersOfTeamWithID:teamID inArray:membersArray page:nextPage 
                                          completionHandler:handler];
                         }
                     }];
    }
}

+ (void)allMembersOfTeamWithID:(NSNumber *)teamID completionHandler:(void (^)(NSMutableArray *members, NSError *error))handler {
    NSMutableArray *members = [NSMutableArray array];
    [self _dumpMembersOfTeamWithID:teamID inArray:members page:1 completionHandler:^(NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            handler(members, nil);
        }
    }];
}

+ (void)_teamWithID:(NSNumber *)teamID removeMembersFromArray:(NSArray *)membersToRemove currentMemberIndex:(NSUInteger)currentMemberIndex completionHandler:(GHAPIErrorHandler)handler {
    if (currentMemberIndex >= membersToRemove.count) {
        handler(nil);
    } else {
        NSString *username = [membersToRemove objectAtIndex:currentMemberIndex];
        [GHAPITeamV3 teamByID:teamID deleteUserNamed:username completionHandler:^(NSError *error) {
            if (error) {
                handler(error);
            } else {
                [self _teamWithID:teamID removeMembersFromArray:membersToRemove currentMemberIndex:currentMemberIndex+1 completionHandler:handler];
            }
        }];
    }
}

+ (void)teamWithID:(NSNumber *)teamID removeMembersFromArray:(NSArray *)array completionHandler:(GHAPIErrorHandler)handler {
    [self _teamWithID:teamID removeMembersFromArray:array currentMemberIndex:0 completionHandler:handler];
}

+ (void)teamByID:(NSNumber *)teamID addUserNamed:(NSString *)username completionHandler:(GHAPIErrorHandler)handler {
    // v3: PUT /teams/:id/members/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/teams/%@/members/%@",
                                       teamID,
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                       ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) {
                                                     [request setRequestMethod:@"PUT"];
                                                 } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                     if ([request responseStatusCode] == 204) {
                                                         handler(nil);
                                                     } else {
                                                         handler(error);
                                                     }
                                                 }];
}

+ (void)_teamWithID:(NSNumber *)teamID addMembersFromArray:(NSArray *)membersToAdd currentMemberIndex:(NSUInteger)currentMemberIndex completionHandler:(GHAPIErrorHandler)handler {
    if (currentMemberIndex >= membersToAdd.count) {
        handler(nil);
    } else {
        NSString *username = [membersToAdd objectAtIndex:currentMemberIndex];
        [GHAPITeamV3 teamByID:teamID addUserNamed:username completionHandler:^(NSError *error) {
            if (error) {
                handler(error);
            } else {
                [self _teamWithID:teamID addMembersFromArray:membersToAdd currentMemberIndex:currentMemberIndex+1 completionHandler:handler];
            }
        }];
    }
}

+ (void)teamWithID:(NSNumber *)teamID addMembersFromArray:(NSArray *)array completionHandler:(GHAPIErrorHandler)handler {
    [self _teamWithID:teamID addMembersFromArray:array currentMemberIndex:0 completionHandler:handler];
}

+ (void)updateTeamWithID:(NSNumber *)teamID setTeamMembers:(NSArray *)newTeamMembers completionHandler:(GHAPIErrorHandler)handler {
    // 1. remove all team members that are not in teamMembers
    // 2. now add all members that are not alread in teamMembers
    [GHAPITeamV3 allMembersOfTeamWithID:teamID completionHandler:^(NSMutableArray *members, NSError *error) {
        if (error) {
            handler(error);
        } else {
            NSMutableArray *removeArray = [NSMutableArray array];
            
            for (GHAPIUserV3 *user in members) {
                if (![newTeamMembers containsObject:user.login]) {
                    [removeArray addObject:user.login];
                }
            }
            
            NSMutableArray *addArray = [NSMutableArray array];
            for (NSString *username in newTeamMembers) {
                BOOL found = NO;
                for (GHAPIUserV3 *user in members) {
                    if ([username isEqualToString:user.login]) {
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [addArray addObject:username];
                }
            }
            
            [GHAPITeamV3 teamWithID:teamID removeMembersFromArray:removeArray completionHandler:^(NSError *error) {
                if (error) {
                    handler(error);
                } else {
                    [self teamWithID:teamID addMembersFromArray:addArray completionHandler:^(NSError *error) {
                        handler(error);
                    }];
                }
            }];
        }
    }];
}

@end
