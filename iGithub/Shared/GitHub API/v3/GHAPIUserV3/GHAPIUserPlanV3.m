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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.space = [rawDictionary objectForKeyOrNilOnNullObject:@"space"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.collaborators = [rawDictionary objectForKeyOrNilOnNullObject:@"collaborators"];
        self.privateRepos = [rawDictionary objectForKeyOrNilOnNullObject:@"private_repos"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_space forKey:@"space"];
    [encoder encodeObject:_collaborators forKey:@"collaborators"];
    [encoder encodeObject:_privateRepos forKey:@"privateRepos"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [decoder decodeObjectForKey:@"name"];
        _space = [decoder decodeObjectForKey:@"space"];
        _collaborators = [decoder decodeObjectForKey:@"collaborators"];
        _privateRepos = [decoder decodeObjectForKey:@"privateRepos"];
    }
    return self;
}

@end
