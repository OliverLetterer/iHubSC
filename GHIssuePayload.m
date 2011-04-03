//
//  GHIssuePayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssuePayload.h"


@implementation GHIssuePayload

@synthesize action=_action, issue=_issue, number=_number;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadIssuesEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKey:@"action"];
        self.issue = [rawDictionary objectForKey:@"issue"];
        self.number = [rawDictionary objectForKey:@"number"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [_issue release];
    [_number release];
    [super dealloc];
}

@end