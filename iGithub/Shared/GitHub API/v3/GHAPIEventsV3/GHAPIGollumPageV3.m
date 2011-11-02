//
//  GHAPIGollumPageV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIGollumPageV3
@synthesize pageName=_pageName, title=_title, action=_action, SHA=_SHA, HTMLURL=_HTMLURL;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super init]) {
        // Initialization code
        _pageName = [rawDictionary objectForKeyOrNilOnNullObject:@"page_name"];
        _title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        _HTMLURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
    }
    return self;
}

@end
