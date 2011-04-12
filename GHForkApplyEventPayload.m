//
//  GHForkApplyEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHForkApplyEventPayload.h"
#import "GithubAPI.h"

@implementation GHForkApplyEventPayload

@synthesize commit=_commit, head=_head, original=_original;

- (GHPayloadEvent)type {
    return GHPayloadForkApplyEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.commit = [rawDictionary objectForKeyOrNilOnNullObject:@"commit"];
        self.head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        self.original = [rawDictionary objectForKeyOrNilOnNullObject:@"original"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_commit release];
    [_head release];
    [_original release];
    [super dealloc];
}

@end
