//
//  GHAPIIssueEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIIssueEventV3.h"
#import "GithubAPI.h"

@implementation GHAPIIssueEventV3

@synthesize URL=_URL, actor=_actor, event=_event, commitID=_commitID, createdAt=_createdAt;
@synthesize type=_type;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.event = [rawDictionay objectForKeyOrNilOnNullObject:@"event"];
        self.commitID = [rawDictionay objectForKeyOrNilOnNullObject:@"commit_id"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        
        self.actor = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"actor"] ] autorelease];
        
        if ([self.event isEqualToString:@"closed"]) {
            _type = GHAPIIssueEventTypeV3Closed;
        } else if ([self.event isEqualToString:@"reopened"]) {
            _type = GHAPIIssueEventTypeV3Reopened;
        } else if ([self.event isEqualToString:@"subscribed"]) {
            _type = GHAPIIssueEventTypeV3Subscribed;
        } else if ([self.event isEqualToString:@"merged"]) {
            _type = GHAPIIssueEventTypeV3Merged;
        } else if ([self.event isEqualToString:@"referenced"]) {
            _type = GHAPIIssueEventTypeV3Referenced;
        } else if ([self.event isEqualToString:@"mentioned"]) {
            _type = GHAPIIssueEventTypeV3Mentioned;
        } else if ([self.event isEqualToString:@"assigned"]) {
            _type = GHAPIIssueEventTypeV3Assigned;
        }
    }
    return self;
}

- (NSComparisonResult)compare:(NSObject *)anObject {
    NSString *compareDateString = nil;
    if ([anObject isKindOfClass:[GHAPIIssueEventV3 class] ]) {
        GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)anObject;
        compareDateString = event.createdAt;
    } else if ([anObject isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
        GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)anObject;
        compareDateString = comment.updatedAt;
    }
    
    return [self.createdAt.dateFromGithubAPIDateString compare:compareDateString.dateFromGithubAPIDateString];
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_actor release];
    [_event release];
    [_commitID release];
    [_createdAt release];
    
    [super dealloc];
}

@end
