//
//  GHActorAttributes.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHActorAttributes.h"


@implementation GHActorAttributes

@synthesize blog=_blog, company=_company, EMail=_EMail, gravatarID=_gravatarID, location=_location, login=_login, name=_name, type=_type;

#pragma mark - initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        self.blog = [rawDictionary objectForKey:@"blog"];
        self.company = [rawDictionary objectForKey:@"company"];
        self.EMail = [rawDictionary objectForKey:@"email"];
        self.gravatarID = [rawDictionary objectForKey:@"gravatar_id"];
        self.location = [rawDictionary objectForKey:@"location"];
        self.login = [rawDictionary objectForKey:@"login"];
        self.name = [rawDictionary objectForKey:@"name"];
        self.type = [rawDictionary objectForKey:@"type"];
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
