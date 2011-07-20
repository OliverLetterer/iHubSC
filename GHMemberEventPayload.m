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
        self.member = [[[GHActorAttributes alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"member"]] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [_member release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.member forKey:@"member"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.member = [aDecoder decodeObjectForKey:@"member"];
    }
    return self;
}

@end
