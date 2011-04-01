//
//  GHPushPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPushPayload.h"
#import "GithubAPI.h"

@implementation GHPushPayload

@synthesize head=_head, ref=_ref, commits=_commits;

#pragma mark - setters and getters

- (GHPayloadType)type {
    return GHPayloadTypePush;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.head = [rawDictionary objectForKey:@"head"];
        self.ref = [rawDictionary objectForKey:@"ref"];
        
        NSMutableArray *commitsArray = [NSMutableArray array];
        NSArray *commits = [rawDictionary objectForKey:@"shas"];
        for (NSArray *commitArray in commits) {
            [commitsArray addObject:[[[GHCommitMessage alloc] initWithRawArray:commitArray] autorelease]];
        }
        self.commits = commitsArray;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_head release];
    [_ref release];
    [_commits release];
    [super dealloc];
}

@end
