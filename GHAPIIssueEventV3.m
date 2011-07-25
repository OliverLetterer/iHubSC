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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.event = [rawDictionary objectForKeyOrNilOnNullObject:@"event"];
        self.commitID = [rawDictionary objectForKeyOrNilOnNullObject:@"commit_id"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        
        self.actor = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"actor"] ] autorelease];
        
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_actor forKey:@"actor"];
    [encoder encodeObject:_event forKey:@"event"];
    [encoder encodeObject:_commitID forKey:@"commitID"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeInteger:_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _actor = [[decoder decodeObjectForKey:@"actor"] retain];
        _event = [[decoder decodeObjectForKey:@"event"] retain];
        _commitID = [[decoder decodeObjectForKey:@"commitID"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _type = [decoder decodeIntegerForKey:@"type"];
    }
    return self;
}

@end
