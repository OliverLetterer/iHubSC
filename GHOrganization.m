//
//  GHOrganization.m
//  iGithub
//
//  Created by Oliver Letterer on 26.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOrganization.h"
#import "GithubAPI.h"

@implementation GHOrganization

@synthesize name=_name, gravatarID=_gravatarID, location=_location, createdAt=_createdAt, blog=_blog, publicGistCount=_publicGistCount, publicRepoCount=_publicRepoCount, followingCount=_followingCount, ID=_ID, type=_type, followersCount=_followersCount, login=_login, EMail=_EMail;

#pragma mark - setters and getters

- (BOOL)hasEMail {
    return self.EMail != nil;
}

- (BOOL)hasLocation {
    return self.location != nil;
}

- (BOOL)hasBlog {
    return self.blog != nil;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        self.publicGistCount = [rawDictionary objectForKeyOrNilOnNullObject:@"public_gist_count"];
        self.publicRepoCount = [rawDictionary objectForKeyOrNilOnNullObject:@"public_repo_count"];
        self.followingCount = [rawDictionary objectForKeyOrNilOnNullObject:@"following_count"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        self.followersCount = [rawDictionary objectForKeyOrNilOnNullObject:@"followers_count"];
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
    }
    return self;
}

+ (void)organizationsOfUser:(NSString *)username completionHandler:(void (^)(NSArray *, NSError *))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /user/show/:user/organizations
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/show/%@/organizations",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
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
                
                NSArray *rawOrganizations = [dictionary objectForKeyOrNilOnNullObject:@"organizations"];
                NSMutableArray *organizations = [NSMutableArray arrayWithCapacity:rawOrganizations.count];
                
                for (NSDictionary *rawDictionary in rawOrganizations) {
                    [organizations addObject:[[[GHOrganization alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(organizations, nil);
            }
        });
    });
}

+ (void)organizationsNamed:(NSString *)name completionHandler:(void (^)(GHOrganization *, NSError *))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /organizations/:org
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/organizations/%@",
                                           [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
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
                
                NSDictionary *rawDictionary = [dictionary objectForKeyOrNilOnNullObject:@"organization"];
                
                handler([[[GHOrganization alloc] initWithRawDictionary:rawDictionary] autorelease], nil);
            }
        });
    });
}

- (void)publicRepositoriesWithCompletionHandler:(void (^)(NSArray *, NSError *))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /organizations/:org/public_repositories
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/organizations/%@/public_repositories",
                                           [self.login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
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
                
                NSArray *rawReposArray = [dictionary objectForKeyOrNilOnNullObject:@"repositories"];
                NSMutableArray *repos = [NSMutableArray arrayWithCapacity:rawReposArray.count];
                
                for (NSDictionary *rawDictionary in rawReposArray) {
                    [repos addObject:[[[GHRepository alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(repos, nil);
            }
        });
    });
}

- (void)publicMembersWithCompletionHandler:(void(^)(NSArray *members, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /organizations/:org/public_members
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/organizations/%@/public_members",
                                           [self.login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
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
                
                NSArray *rawMembersArray = [dictionary objectForKeyOrNilOnNullObject:@"users"];
                NSMutableArray *members = [NSMutableArray arrayWithCapacity:rawMembersArray.count];
                
                for (NSDictionary *rawDictionary in rawMembersArray) {
                    [members addObject:[[[GHUser alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(members, nil);
            }
        });
    });
}

- (void)teamsWithCompletionHandler:(void(^)(NSArray *teams, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /organizations/:org/teams
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/organizations/%@/teams",
                                           [self.login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
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
                
                NSArray *rawArray = [dictionary objectForKeyOrNilOnNullObject:@"teams"];
                NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                
                for (NSDictionary *rawDictionary in rawArray) {
                    [finalArray addObject:[[[GHTeam alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(finalArray, nil);
            }
        });
    });
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    [_gravatarID release];
    [_location release];
    [_createdAt release];
    [_blog release];
    [_publicGistCount release];
    [_publicRepoCount release];
    [_followingCount release];
    [_ID release];
    [_type release];
    [_followersCount release];
    [_login release];
    [_EMail release];
    
    [super dealloc];
}

@end
