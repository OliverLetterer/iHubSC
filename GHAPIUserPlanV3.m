//
//  GHAPIUserPlanV3.m
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIUserPlanV3.h"
#import "GithubAPI.h"

@implementation GHAPIUserPlanV3

@synthesize space=_space, name=_name, collaborators=_collaborators, privateRepos=_privateRepos;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.space = [rawDictionay objectForKeyOrNilOnNullObject:@"space"];
        self.name = [rawDictionay objectForKeyOrNilOnNullObject:@"name"];
        self.collaborators = [rawDictionay objectForKeyOrNilOnNullObject:@"collaborators"];
        self.privateRepos = [rawDictionay objectForKeyOrNilOnNullObject:@"private_repos"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_space release];
    [_name release];
    [_collaborators release];
    [_privateRepos release];
    
    [super dealloc];
}

@end
