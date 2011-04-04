//
//  GHIssueComment.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueComment.h"
#import "GithubAPI.h"

@implementation GHIssueComment

@synthesize body=_body, createdAt=_createdAt, gravatarID=_gravatarID, ID=_ID, updatedAt=_updatedAt, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.user = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_body release];
    [_createdAt release];
    [_gravatarID release];
    [_ID release];
    [_updatedAt release];
    [_user release];
    [super dealloc];
}

@end
