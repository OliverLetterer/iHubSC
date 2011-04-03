//
//  GHPayloadWithActor.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayloadWithActor.h"
#import "GithubAPI.h"

@implementation GHPayloadWithActor

@synthesize actor=_actor, gravatarID=_gravatarID;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.actor = [rawDictionary objectForKeyOrNilOnNullObject:@"actor"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"actor_gravatar"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_actor release];
    [_gravatarID release];
    [super dealloc];
}

@end
