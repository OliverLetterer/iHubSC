//
//  GHDownloadEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDownloadEventPayload.h"
#import "GithubAPI.h"

@implementation GHDownloadEventPayload

@synthesize ID=_ID, URL=_URL;

- (GHPayloadEvent)type {
    return GHPayloadDownloadEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_URL release];
    [super dealloc];
}

@end
