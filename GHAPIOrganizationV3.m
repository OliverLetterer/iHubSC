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
        _login = [[decoder decodeObjectForKey:@"login"] retain];
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _avatarURL = [[decoder decodeObjectForKey:@"avatarURL"] retain];
        _gravatarID = [[decoder decodeObjectForKey:@"gravatarID"] retain];
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _company = [[decoder decodeObjectForKey:@"company"] retain];
        _blog = [[decoder decodeObjectForKey:@"blog"] retain];
        _location = [[decoder decodeObjectForKey:@"location"] retain];
        _EMail = [[decoder decodeObjectForKey:@"eMail"] retain];
        _publicRepos = [[decoder decodeObjectForKey:@"publicRepos"] retain];
        _publicGists = [[decoder decodeObjectForKey:@"publicGists"] retain];
        _follower = [[decoder decodeObjectForKey:@"follower"] retain];
        _following = [[decoder decodeObjectForKey:@"following"] retain];
        _HTMLURL = [[decoder decodeObjectForKey:@"hTMLURL"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _type = [[decoder decodeObjectForKey:@"type"] retain];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_login release];
    [_ID release];
    [_URL release];
    [_avatarURL release];
    [_gravatarID release];
    [_name release];
    [_company release];
    [_blog release];
    [_location release];
    [_EMail release];
    [_publicRepos release];
    [_publicGists release];
    [_follower release];
    [_following release];
    [_HTMLURL release];
    [_createdAt release];
    [_type release];
    
    [super dealloc];
}

#pragma mark - downloading

+ (void)organizationsOfUser:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /users/:user/orgs
    // v3: GET /user/orgs           - for authenticated user
    
    NSURL *URL = nil;
    
    if ([username isEqualToString:[GHAuthenticationManager sharedInstance].username]) {
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
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPIOrganizationV3 alloc] initWithRawDictionary:obj] autorelease] ];
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
                                               handler([[[GHAPIOrganizationV3 alloc] initWithRawDictionary:object] autorelease], nil);
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
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPIRepositoryV3 alloc] initWithRawDictionary:obj] autorelease] ];
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
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPIUserV3 alloc] initWithRawDictionary:obj] autorelease] ];
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
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[[GHAPITeamV3 alloc] initWithRawDictionary:obj] autorelease] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

@end
