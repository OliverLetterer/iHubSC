//
//  GHTeam.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTeam.h"
#import "GithubAPI.h"

@implementation GHTeam

@synthesize name=_name, ID=_ID, permission=_permission;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        // Initialization code
        self.name = [dictionary objectForKeyOrNilOnNullObject:@"name"];
        self.ID = [dictionary objectForKeyOrNilOnNullObject:@"id"];
        self.permission = [dictionary objectForKeyOrNilOnNullObject:@"permission"];
    }
    return self;
}

- (void)deleteWithCompletionHandler:(void(^)(NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /teams/:team_id
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/teams/%@",
                                           self.ID ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setRequestMethod:@"DELETE"];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            handler(myError);
        });
    });
}

- (void)deleteMember:(NSString *)login withCompletionHandler:(void(^)(NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /teams/:team_id/members?name=:user [DELETE]
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/teams/%@/members?name=%@",
                                           self.ID, [login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setRequestMethod:@"DELETE"];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            handler(myError);
        });
    });
}

- (void)deleteRepository:(NSString *)repo withCompletionHandler:(void(^)(NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /teams/:team_id/repositories?name=:user/:repo [DELETE]
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/teams/%@/repositories?name=%@",
                                           self.ID, [repo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setRequestMethod:@"DELETE"];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            handler(myError);
        });
    });
}

- (void)membersWithCompletionHandler:(void(^)(NSArray *members, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /teams/:team_id/members
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/teams/%@/members",
                                           self.ID ] ];
        
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
                
                NSArray *rawArray = [dictionary objectForKeyOrNilOnNullObject:@"users"];
                NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                
                for (NSDictionary *rawDictionary in rawArray) {
                    [finalArray addObject:[[[GHUser alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(finalArray, nil);
            }
        });
    });
}

- (void)repositoriesWithCompletionHandler:(void(^)(NSArray *repos, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // /teams/:team_id/repositories
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/teams/%@/repositories",
                                           self.ID ] ];
        
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
                
                NSArray *rawArray = [dictionary objectForKeyOrNilOnNullObject:@"repositories"];
                NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                
                for (NSDictionary *rawDictionary in rawArray) {
                    [finalArray addObject:[[[GHRepository alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                }
                
                handler(finalArray, nil);
            }
        });
    });
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    [_ID release];
    [_permission release];
    
    [super dealloc];
}

@end
