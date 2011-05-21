//
//  GHAPIGistCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistCommentV3.h"
#import "GithubAPI.h"

@implementation GHAPIGistCommentV3

@synthesize ID=_ID, URL=_URL, body=_body, user=_user, createdAt=_createdAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.ID = [rawDictionay objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.body = [rawDictionay objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        
        self.user = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_URL release];
    [_body release];
    [_user release];
    [_createdAt release];
    [super dealloc];
}

@end
