//
//  GHPullRequestPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestPayload.h"
#import "GithubAPI.h"

@implementation GHPullRequestPayload

@synthesize number=_number, action=_action, pullRequest=_pullRequest;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadPullRequestEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        NSObject *pullRequest = [rawDictionary objectForKeyOrNilOnNullObject:@"pull_request"];
        if ([pullRequest isKindOfClass:[NSDictionary class]]) {
            self.pullRequest = [[GHPullRequest alloc] initWithRawDictionary:(NSDictionary *)pullRequest];
        }
        // Initialization code
        
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.pullRequest forKey:@"pullRequest"];
    [aCoder encodeObject:self.number forKey:@"number"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.pullRequest = [aDecoder decodeObjectForKey:@"pullRequest"];
        self.number = [aDecoder decodeObjectForKey:@"number"];
    }
    return self;
}

@end
