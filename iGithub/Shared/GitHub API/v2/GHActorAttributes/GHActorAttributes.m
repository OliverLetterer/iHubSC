//
//  GHActorAttributes.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHActorAttributes.h"
#import "GithubAPI.h"

@implementation GHActorAttributes

@synthesize blog=_blog, company=_company, EMail=_EMail, gravatarID=_gravatarID, location=_location, login=_login, name=_name, type=_type;

#pragma mark - initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        self.company = [rawDictionary objectForKeyOrNilOnNullObject:@"company"];
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
    }
    return self;
}

#pragma mark - memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.blog forKey:@"blog"];
    [aCoder encodeObject:self.company forKey:@"company"];
    [aCoder encodeObject:self.EMail forKey:@"EMail"];
    [aCoder encodeObject:self.gravatarID forKey:@"gravatarID"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.login forKey:@"login"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.blog = [aDecoder decodeObjectForKey:@"blog"];
        self.company = [aDecoder decodeObjectForKey:@"company"];
        self.EMail = [aDecoder decodeObjectForKey:@"EMail"];
        self.gravatarID = [aDecoder decodeObjectForKey:@"gravatarID"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.login = [aDecoder decodeObjectForKey:@"login"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
    }
    return self;
}

@end
