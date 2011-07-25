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
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.pageName forKey:@"pageName"];
    [aCoder encodeObject:self.sha forKey:@"sha"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.pageName = [aDecoder decodeObjectForKey:@"pageName"];
        self.sha = [aDecoder decodeObjectForKey:@"sha"];
        self.summary = [aDecoder decodeObjectForKey:@"summary"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
