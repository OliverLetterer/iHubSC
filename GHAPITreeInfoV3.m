//
//  GHAPITreeInfoV3.m
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPITreeInfoV3.h"
#import "GithubAPI.h"

@implementation GHAPITreeInfoV3

@synthesize URL = _URL, SHA = _SHA;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_SHA release];
    
    [super dealloc];
}

@end
