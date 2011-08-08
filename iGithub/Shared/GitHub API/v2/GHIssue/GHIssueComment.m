//
//  GHIssueComment.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueComment.h"
#import "GithubAPI.h"

@implementation GHIssueComment

@synthesize body=_body, createdAt=_createdAt, gravatarID=_gravatarID, ID=_ID, updatedAt=_updatedAt, user=_user, userInfo=_userInfo;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        id<NSObject> user = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
        if ([user isKindOfClass:[NSString class] ]) {
            self.user = (NSString *)user;
        } else if ([user isKindOfClass:[NSDictionary class] ]) {
            self.userInfo = [[GHUser alloc] initWithRawDictionary:(NSDictionary *)user];
        }
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _body = [decoder decodeObjectForKey:@"body"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _gravatarID = [decoder decodeObjectForKey:@"gravatarID"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
        _user = [decoder decodeObjectForKey:@"user"];
        _userInfo = [decoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

@end
