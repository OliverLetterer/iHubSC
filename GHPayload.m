//
//  GHPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayload.h"


@implementation GHPayload

@synthesize actor=_actor, gravatarID=_gravatarID;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadNoEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.actor = [rawDictionary objectForKey:@"actor"];
        self.gravatarID = [rawDictionary objectForKey:@"actor_gravatar"];
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
