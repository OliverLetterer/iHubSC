//
//  GHAPIIssuesEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIIssuesEventV3
@synthesize action=_action, issue=_issue;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _issue = [[GHAPIIssueV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"issue"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_action forKey:@"action"];
    [encoder encodeObject:_issue forKey:@"issue"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _action = [decoder decodeObjectForKey:@"action"];
        _issue = [decoder decodeObjectForKey:@"issue"];
    }
    return self;
}

@end
