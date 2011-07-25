//
//  GHPullRequestRepositoryInformation.m
//  iGithub
//
//  Created by Oliver Letterer on 16.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestRepositoryInformation.h"


@implementation GHPullRequestRepositoryInformation

@synthesize label=_label, ref=_ref, repository=_repository, sha=_sha, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.label = [rawDictionary objectForKeyOrNilOnNullObject:@"label"];
        self.ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        self.sha = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repository"] ] autorelease];
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_label release];
    [_ref release];
    [_repository release];
    [_sha release];
    [_user release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_ref forKey:@"ref"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_sha forKey:@"sha"];
    [encoder encodeObject:_user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _label = [[decoder decodeObjectForKey:@"label"] retain];
        _ref = [[decoder decodeObjectForKey:@"ref"] retain];
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
        _sha = [[decoder decodeObjectForKey:@"sha"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
    }
    return self;
}

@end
