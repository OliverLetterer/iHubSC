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

- (void)dealloc {
    [_blog release];
    [_company release];
    [_EMail release];
    [_gravatarID release];
    [_location release];
    [_login release];
    [_name release];
    [_type release];
    
    [super dealloc];
}

@end
