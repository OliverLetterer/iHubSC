//
//  GHAPIPullRequestMergeState.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIPullRequestMergeStateV3.h"
#import "GithubAPI.h"

@implementation GHAPIPullRequestMergeStateV3

@synthesize SHA=_SHA, merged=_merged, message=_message;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.merged = [rawDictionary objectForKeyOrNilOnNullObject:@"merged"];
        self.message = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_SHA release];
    [_merged release];
    [_message release];
    
    [super dealloc];
}

@end
