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
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_SHA forKey:@"sHA"];
    [encoder encodeObject:_merged forKey:@"merged"];
    [encoder encodeObject:_message forKey:@"message"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _SHA = [[decoder decodeObjectForKey:@"sHA"] retain];
        _merged = [[decoder decodeObjectForKey:@"merged"] retain];
        _message = [[decoder decodeObjectForKey:@"message"] retain];
    }
    return self;
}

@end
