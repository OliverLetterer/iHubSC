//
//  GHIssuesCommentPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssuesCommentPayload.h"
#import "GithubAPI.h"

@implementation GHIssuesCommentPayload

@synthesize commentID=_commentID, issueID=_issueID;

- (GHPayloadEvent)type {
    return GHPayloadIssueCommentEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary URL:(NSString *)URL {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.commentID = [rawDictionary objectForKeyOrNilOnNullObject:@"comment_id"];
        self.issueID = [rawDictionary objectForKeyOrNilOnNullObject:@"issue_id"];
        
        NSString *commentIDString = [URL substringBetweenLeftBounds:@"issues/" andRightBounds:@"#"];
        int ID = [commentIDString intValue];
        self.issueID = [NSNumber numberWithInt:ID];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_commentID release];
    [_issueID release];
    [super dealloc];
}

@end
