//
//  GHGollumEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGollumEventPayload.h"
#import "GithubAPI.h"

@implementation GHGollumEventPayload

@synthesize action=_action, pageName=_pageName, sha=_sha, summary=_summary, title=_title;

- (GHPayloadEvent)type {
    return GHPayloadGollumEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        self.pageName = [rawDictionary objectForKeyOrNilOnNullObject:@"page_name"];
        self.sha = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.summary = [rawDictionary objectForKeyOrNilOnNullObject:@"summary"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [_pageName release];
    [_sha release];
    [_summary release];
    [_title release];
    
    [super dealloc];
}

@end
