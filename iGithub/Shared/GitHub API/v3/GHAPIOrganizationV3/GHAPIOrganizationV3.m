//
//  GHAPIOrganizationV3.m
//  iGithub
//
//  Created by Oliver Letterer on 12.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIOrganizationV3.h"
#import "GithubAPI.h"

@implementation GHAPIOrganizationV3

@synthesize login = _login, ID = _ID, URL = _URL, avatarURL = _avatarURL, gravatarID = _gravatarID, name = _name, company = _company, blog = _blog, location = _location, EMail = _EMail, publicRepos = _publicRepos, publicGists = _publicGists, follower = _follower, following = _following, HTMLURL = _HTMLURL, createdAt = _createdAt, type = _type;

#pragma mark - setters and getters

- (BOOL)hasBlog {
    return self.blog != nil;
}

- (BOOL)hasLocation {
    return self.location != nil;
}

- (BOOL)hasEMail {
    return self.EMail != nil;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.avatarURL = [rawDictionary objectForKeyOrNilOnNullObject:@"avatar_url"];
        self.gravatarID = self.avatarURL.gravarID;
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.company = [rawDictionary objectForKeyOrNilOnNullObject:@"company"];
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
        self.publicRepos = [rawDictionary objectForKeyOrNilOnNullObject:@"public_repos"];
        self.publicGists = [rawDictionary objectForKeyOrNilOnNullObject:@"public_gists"];
        self.follower = [rawDictionary objectForKeyOrNilOnNullObject:@"followers"];
        self.following = [rawDictionary objectForKeyOrNilOnNullObject:@"following"];
        self.HTMLURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_login forKey:@"login"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_avatarURL forKey:@"avatarURL"];
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_company forKey:@"company"];
    [encoder encodeObject:_blog forKey:@"blog"];
    [encoder encodeObject:_location forKey:@"location"];
    [encoder encodeObject:_EMail forKey:@"eMail"];
    [encoder encodeObject:_publicRepos forKey:@"publicRepos"];
    [encoder encodeObject:_publicGists forKey:@"publicGists"];
    [encoder encodeObject:_follower forKey:@"follower"];
    [encoder encodeObject:_following forKey:@"following"];
    [encoder encodeObject:_HTMLURL forKey:@"hTMLURL"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _login = [decoder decodeObjectForKey:@"login"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _avatarURL = [decoder decodeObjectForKey:@"avatarURL"];
        _gravatarID = [decoder decodeObjectForKey:@"gravatarID"];
        _name = [decoder decodeObjectForKey:@"name"];
        _company = [decoder decodeObjectForKey:@"company"];
        _blog = [decoder decodeObjectForKey:@"blog"];
        _location = [decoder decodeObjectForKey:@"location"];
        _EMail = [decoder decodeObjectForKey:@"eMail"];
        _publicRepos = [decoder decodeObjectForKey:@"publicRepos"];
        _publicGists = [decoder decodeObjectForKey:@"publicGists"];
        _follower = [decoder decodeObjectForKey:@"follower"];
        _following = [decoder decodeObjectForKey:@"following"];
        _HTMLURL = [decoder decodeObjectForKey:@"hTMLURL"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _type = [decoder decodeObjectForKey:@"type"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - downloading

+ (void)organizationsOfUser:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /users/:user/orgs
    // v3: GET /user/orgs           - for authenticated user
    
    NSURL *URL = nil;
    
    if ([username isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/orgs"]];
    } else {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/orgs",
                                    [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    }
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIOrganizationV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)organizationByName:(NSString *)organizationName completionHandler:(void (^)(GHAPIOrganizationV3 *organization, NSError *error))handler {
    // v3: GET /orgs/:org
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@",
                                       [organizationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIOrganizationV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)repositoriesOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /orgs/:org/repos
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@/repos",
                                       [organizationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    
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

+ (void)membersOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /orgs/:org/members
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@/members",
                                       [organizationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    
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

+ (void)teamsOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /orgs/:org/teams
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@/teams",
                                       [organizationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPITeamV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)createTeamForOrganization:(NSString *)organization name:(NSString *)name permission:(NSString *)permission repositories:(NSArray *)repositories teamMembers:(NSArray *)teamMembers completionHandler:(void (^)(GHAPITeamV3 *team, NSError *error))handler {
    // v3: POST /orgs/:org/teams
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@/teams",
                                       [organization stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) { 
                                                     [request setRequestMethod:@"POST"];
                                                     NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
                                                     
                                                     if (name) {
                                                         [jsonDictionary setObject:name forKey:@"name"];
                                                     }
                                                     if (permission) {
                                                         [jsonDictionary setObject:permission forKey:@"permission"];
                                                     }
                                                     if (repositories) {
                                                         [jsonDictionary setObject:repositories forKey:@"repo_names"];
                                                     }
                                                     NSString *jsonString = [jsonDictionary JSONString];
                                                     NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                     
                                                     [request setPostBody:jsonData];
                                                     [request setPostLength:[jsonString length] ];
                                                 } 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    GHAPITeamV3 *team = [[GHAPITeamV3 alloc] initWithRawDictionary:object];
                                                    [GHAPITeamV3 updateTeamWithID:team.ID setTeamMembers:teamMembers 
                                                                completionHandler:^(NSError *error) {
                                                                    handler(team, error);
                                                                }];
                                                }
                                            }];
}

+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization nextPate:(NSUInteger)nextPage inArray:(NSMutableArray *)teamsArray currentTeamIndex:(NSUInteger)currentTeamIndex completionHandler:(GHAPIStateHandler)handler {
    if (currentTeamIndex >= teamsArray.count) {
        // exceded teamsarrays bounds, so get next set of teams
        [self isUser:username administratorInOrganization:organization checkTeamsWithPage:nextPage completionHandler:handler];
    } else {
        // now ask the team, if user is a member
        GHAPITeamV3 *badTeam = [teamsArray objectAtIndex:currentTeamIndex];
        [GHAPITeamV3 teamByID:badTeam.ID 
            completionHandler:^(GHAPITeamV3 *team, NSError *error) {
                if ([team.permission isEqualToString:GHAPITeamV3PermissionAdmin]) {
                    // this team has admin right, check if user is member
                    [GHAPITeamV3 isUser:username memberInTeamByID:team.ID completionHandler:^(BOOL state, NSError *error) {
                        if (error) {
                            // error happend
                            handler(NO, error);
                        } else {
                            if (state) {
                                // user is member
                                handler(YES, nil);
                            } else {
                                // user is no member, check for next team
                                [self isUser:username administratorInOrganization:organization nextPate:nextPage inArray:teamsArray currentTeamIndex:currentTeamIndex+1 completionHandler:handler];
                            }
                        }
                    }];
                } else {
                    // this team does not have admin right, check next team
                    [self isUser:username administratorInOrganization:organization nextPate:nextPage inArray:teamsArray currentTeamIndex:currentTeamIndex+1 completionHandler:handler];
                }
            }];
    }
}

+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization checkTeamsWithPage:(NSUInteger)page completionHandler:(GHAPIStateHandler)handler {
    if (page == GHAPIPaginationNextPageNotFound) {
        // no more page is available, member is not in any admin group. end
        handler(NO, nil);
    } else {
        // we can get this page
        [GHAPIOrganizationV3 teamsOfOrganizationNamed:organization page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            handler(NO, error);
                                        } else {
                                            // enumerate teams and check if user is a member
                                            [self isUser:username administratorInOrganization:organization nextPate:nextPage 
                                                 inArray:array currentTeamIndex:0 completionHandler:handler];
                                        }
                                    }];
    }
}

+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization completionHandler:(GHAPIStateHandler)handler {
    [self isUser:username administratorInOrganization:organization checkTeamsWithPage:1 completionHandler:handler];
}

@end
