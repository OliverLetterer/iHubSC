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
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
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

@end
