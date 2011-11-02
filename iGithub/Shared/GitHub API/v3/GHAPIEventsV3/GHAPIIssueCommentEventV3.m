//
//  GHAPIIssueCommentEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIIssueCommentEventV3
@synthesize action=_action, issue=_issue, comment=_comment;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _issue = [[GHAPIIssueV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"issue"] ];
        _comment = [[GHAPIIssueCommentV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"comment"] ];
    }
    return self;
}

@end
