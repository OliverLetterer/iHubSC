//
//  GHIssueCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueCommentV3.h"
#import "GithubAPI.h"

@implementation GHIssueCommentV3

@synthesize URL=_URL, body=_body, user=_user, createdAt=_createdAt, updatedAt=_updatedAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        
        self.user = [[[GHUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_body release];
    [_user release];
    [_createdAt release];
    [_updatedAt release];
    
    [super dealloc];
}

@end
