//
//  GHCommitEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitEventPayload.h"
#import "GithubAPI.h"

@implementation GHCommitEventPayload

@synthesize commentID=_commentID, commit=_commit;

- (GHPayloadEvent)type {
    return GHPayloadCommitCommentEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.commit = [rawDictionary objectForKeyOrNilOnNullObject:@"commit"];
        self.commentID = [rawDictionary objectForKeyOrNilOnNullObject:@"comment_id"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_commentID release];
    [_commit release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.commit forKey:@"commit"];
    [aCoder encodeObject:self.commentID forKey:@"commentID"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.commit = [aDecoder decodeObjectForKey:@"commit"];
        self.commentID = [aDecoder decodeObjectForKey:@"commentID"];
    }
    return self;
}

@end
