//
//  GHTarget.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTarget.h"


@implementation GHTarget

@synthesize followers=_followers, gravatarID=_gravatarID, login=_login, repos=_repos;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.followers = [rawDictionary objectForKey:@"followers"];
        self.gravatarID = [rawDictionary objectForKey:@"gravatar_id"];
        self.login = [rawDictionary objectForKey:@"login"];
        self.repos = [rawDictionary objectForKey:@"repos"];
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
