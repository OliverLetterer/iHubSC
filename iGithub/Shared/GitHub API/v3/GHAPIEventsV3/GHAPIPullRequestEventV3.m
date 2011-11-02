//
//  GHAPIPullRequestEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIPullRequestEventV3
@synthesize pullRequest=_pullRequest, action=_action, number=_number;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _pullRequest = [[GHAPIIssueV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"pull_request"] ];
    }
    return self;
}

@end
