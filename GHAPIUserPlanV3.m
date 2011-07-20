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

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_space forKey:@"space"];
    [encoder encodeObject:_collaborators forKey:@"collaborators"];
    [encoder encodeObject:_privateRepos forKey:@"privateRepos"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _space = [[decoder decodeObjectForKey:@"space"] retain];
        _collaborators = [[decoder decodeObjectForKey:@"collaborators"] retain];
        _privateRepos = [[decoder decodeObjectForKey:@"privateRepos"] retain];
    }
    return self;
}

@end
