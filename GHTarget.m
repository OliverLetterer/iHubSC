//
//  GHTarget.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTarget.h"
#import "GithubAPI.h"

@implementation GHTarget

@synthesize followers=_followers, gravatarID=_gravatarID, login=_login, repos=_repos;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.followers = [rawDictionary objectForKeyOrNilOnNullObject:@"followers"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.repos = [rawDictionary objectForKeyOrNilOnNullObject:@"repos"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_followers release];
    [_gravatarID release];
    [_login release];
    [_repos release];
    [super dealloc];
}

@end
