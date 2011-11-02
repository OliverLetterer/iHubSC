//
//  GHAPICommitCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPICommitCommentV3
@synthesize URL = _URL, ID = _ID, body = _body, path = _path, position = _position, commitID = _commitID, user = _user, createdAt = _createdAt, updatedAt = _updatedAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super init]) {
        // Initialization code
        _URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        _ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        _body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        _path = [rawDictionary objectForKeyOrNilOnNullObject:@"path"];
        _position = [rawDictionary objectForKeyOrNilOnNullObject:@"position"];
        _commitID = [rawDictionary objectForKeyOrNilOnNullObject:@"commit_id"];
        _createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        _updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        
        _user = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_path forKey:@"path"];
    [encoder encodeObject:_position forKey:@"position"];
    [encoder encodeObject:_commitID forKey:@"commitID"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _body = [decoder decodeObjectForKey:@"body"];
        _path = [decoder decodeObjectForKey:@"path"];
        _position = [decoder decodeObjectForKey:@"position"];
        _commitID = [decoder decodeObjectForKey:@"commitID"];
        _user = [decoder decodeObjectForKey:@"user"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
    }
    return self;
}

@end
