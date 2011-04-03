//
//  GHMemberEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHMemberEventPayload.h"
#import "GithubAPI.h"

@implementation GHMemberEventPayload

@synthesize action=_action, member=_member;

- (GHPayloadEvent)type {
    return GHPayloadMemberEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        self.member = [rawDictionary objectForKeyOrNilOnNullObject:@"member"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [_member release];
    [super dealloc];
}

@end
