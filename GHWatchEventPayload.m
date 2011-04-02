//
//  GHWatchEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHWatchEventPayload.h"


@implementation GHWatchEventPayload

@synthesize action=_action;

- (GHPayloadEvent)type {
    return GHPayloadWatchEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKey:@"action"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [super dealloc];
}

@end
