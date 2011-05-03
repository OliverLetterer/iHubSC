//
//  GHGist.m
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGist.h"
#import "GithubAPI.h"

@implementation GHGist

@synthesize URL=_URL, ID=_ID, description=_description, public=_public, user=_user, files=_files, comments=_comments, pullURL=_pullURL, pushURL=_pushURL, createdAt=_createdAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.ID = [rawDictionay objectForKeyOrNilOnNullObject:@"id"];
        self.description = [rawDictionay objectForKeyOrNilOnNullObject:@"description"];
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"]] autorelease];
        self.comments = [rawDictionay objectForKeyOrNilOnNullObject:@"comments"];
        self.pullURL = [rawDictionay objectForKeyOrNilOnNullObject:@"git_pull_url"];
        self.pushURL = [rawDictionay objectForKeyOrNilOnNullObject:@"git_push_url"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.public = [rawDictionay objectForKeyOrNilOnNullObject:@"public"];
        
        NSDictionary *filesDictionary = [rawDictionay objectForKeyOrNilOnNullObject:@"files"];
        NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:[filesDictionary count]];
        
        [filesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [filesArray addObject:[[[GHGistFile alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        
        self.files = filesArray;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_ID release];
    [_description release];
    [_public release];
    [_user release];
    [_files release];
    [_comments release];
    [_pullURL release];
    [_pushURL release];
    [_createdAt release];
    
    [super dealloc];
}

@end
