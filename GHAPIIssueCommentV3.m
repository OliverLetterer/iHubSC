//
//  GHAPIIssueCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIIssueCommentV3.h"
#import "GithubAPI.h"

@implementation GHAPIIssueCommentV3

@synthesize URL=_URL, body=_body, attributedBody=_attributedBody, user=_user, createdAt=_createdAt, updatedAt=_updatedAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.attributedBody = self.body.attributesStringFromMarkdownString;
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        
        self.user = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
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
    
    return [self.updatedAt.dateFromGithubAPIDateString compare:compareDateString.dateFromGithubAPIDateString];
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_body release];
    [_user release];
    [_attributedBody release];
    [_createdAt release];
    [_updatedAt release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_attributedBody forKey:@"attributedBody"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _body = [[decoder decodeObjectForKey:@"body"] retain];
        _attributedBody = [[decoder decodeObjectForKey:@"attributedBody"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _updatedAt = [[decoder decodeObjectForKey:@"updatedAt"] retain];
    }
    return self;
}

@end
