//
//  GHCommitEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitEventPayload.h"


@implementation GHCommitEventPayload

@synthesize commentID=_commentID, commit=_commit;

- (GHPayloadType)type {
    return GHPayloadTypeCommitComment;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.commit = [rawDictionary objectForKey:@"commit"];
        self.commentID = [rawDictionary objectForKey:@"comment_id"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_commentID release];
    [_commit release];
    [super dealloc];
}

@end
