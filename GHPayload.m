//
//  GHPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayload.h"
#import "GithubAPI.h"

@implementation GHPayload

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadNoEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [super dealloc];
}

@end
