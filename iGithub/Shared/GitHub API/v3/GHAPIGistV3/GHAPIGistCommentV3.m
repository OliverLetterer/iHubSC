//
//  GHAPIGistCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistCommentV3.h"
#import "GithubAPI.h"
#import "WASelectedAttributedMarkdownFormatter.h"
#import "NSAttributedString+HTML.h"

@implementation GHAPIGistCommentV3
@synthesize ID=_ID, URL=_URL, body=_body, user=_user, createdAt=_createdAt;
@synthesize attributedBody=_attributedBody, selectedAttributedBody=_selectedAttributedBody;

- (NSAttributedString *)attributedBody {
    if (!_attributedBody) {
        _attributedBody = self.body.attributesStringFromMarkdownString;
    }
    return _attributedBody;
}

- (NSAttributedString *)selectedAttributedBody {
    if (!_selectedAttributedBody) {
        WASelectedAttributedMarkdownFormatter *formatter = [[WASelectedAttributedMarkdownFormatter alloc] init];
        NSString *HTML = [formatter HTMLForMarkdown:self.body];
        NSData *HTMLData = [HTML dataUsingEncoding:NSUTF8StringEncoding];
        _selectedAttributedBody = [NSAttributedString attributedStringWithHTML:HTMLData options:nil];
    }
    return _selectedAttributedBody;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        
        self.user = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _ID = [decoder decodeObjectForKey:@"iD"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _body = [decoder decodeObjectForKey:@"body"];
        _user = [decoder decodeObjectForKey:@"user"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
    }
    return self;
}

@end
