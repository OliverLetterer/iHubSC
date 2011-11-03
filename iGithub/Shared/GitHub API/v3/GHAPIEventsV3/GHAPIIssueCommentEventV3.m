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

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _issue = [[GHAPIIssueV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"issue"] ];
        _comment = [[GHAPIIssueCommentV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"comment"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_action forKey:@"action"];
    [encoder encodeObject:_issue forKey:@"issue"];
    [encoder encodeObject:_comment forKey:@"comment"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _action = [decoder decodeObjectForKey:@"action"];
        _issue = [decoder decodeObjectForKey:@"issue"];
        _comment = [decoder decodeObjectForKey:@"comment"];
    }
    return self;
}

@end
