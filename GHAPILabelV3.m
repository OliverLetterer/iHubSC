//
//  GHAPILabelV3.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPILabelV3.h"
#import "GithubAPI.h"

@implementation GHAPILabelV3

@synthesize URL=_URL, name=_name, colorString=_colorString;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.colorString = [rawDictionary objectForKeyOrNilOnNullObject:@"color"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_name release];
    [_colorString release];
    
    [super dealloc];
}

@end
