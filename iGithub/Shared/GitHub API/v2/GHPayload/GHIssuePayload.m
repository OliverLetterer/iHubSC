//
//  GHIssuePayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssuePayload.h"
#import "GithubAPI.h"

@implementation GHIssuePayload

@synthesize action=_action, issue=_issue, number=_number;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadIssuesEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        self.issue = [rawDictionary objectForKeyOrNilOnNullObject:@"issue"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.issue forKey:@"issue"];
    [aCoder encodeObject:self.number forKey:@"number"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.issue = [aDecoder decodeObjectForKey:@"issue"];
        self.number = [aDecoder decodeObjectForKey:@"number"];
    }
    return self;
}

@end
