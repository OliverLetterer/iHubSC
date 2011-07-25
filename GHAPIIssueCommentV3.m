//
//  GHAPIIssueCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIIssueCommentV3.h"
#import "GithubAPI.h"
#import "WASelectedAttributedMarkdownFormatter.h"
#import "NSAttributedString+HTML.h"

@implementation GHAPIIssueCommentV3

@synthesize URL=_URL, body=_body, user=_user, createdAt=_createdAt, updatedAt=_updatedAt;
@synthesize attributedBody=_attributedBody, selectedAttributedBody=_selectedAttributedBody;

#pragma mark - Setters and getters

- (NSAttributedString *)attributedBody {
    if (!_attributedBody) {
        _attributedBody = [self.body.attributesStringFromMarkdownString retain];
    }
    return _attributedBody;
}

- (NSAttributedString *)selectedAttributedBody {
    if (!_selectedAttributedBody) {
        WASelectedAttributedMarkdownFormatter *formatter = [[[WASelectedAttributedMarkdownFormatter alloc] init] autorelease];
        NSString *HTML = [formatter HTMLForMarkdown:self.body];
        NSData *HTMLData = [HTML dataUsingEncoding:NSUTF8StringEncoding];
        _selectedAttributedBody = [[NSAttributedString attributedStringWithHTML:HTMLData options:nil] retain];
    }
    return _selectedAttributedBody;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
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
    [_createdAt release];
    [_updatedAt release];
    [_attributedBody release];
    [_selectedAttributedBody release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _body = [[decoder decodeObjectForKey:@"body"] retain];
        self.attributedBody = _body.attributesStringFromMarkdownString;
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _updatedAt = [[decoder decodeObjectForKey:@"updatedAt"] retain];
    }
    return self;
}

@end
