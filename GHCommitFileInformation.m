//
//  GHCommitFileInformation.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitFileInformation.h"
#import "GithubAPI.h"

@implementation GHCommitFileInformation

@synthesize diff=_diff, filename=_filename;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.diff = [rawDictionary objectForKeyOrNilOnNullObject:@"diff"];
        self.filename = [rawDictionary objectForKeyOrNilOnNullObject:@"filename"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_diff release];
    [_filename release];
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_diff forKey:@"diff"];
    [encoder encodeObject:_filename forKey:@"filename"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _diff = [[decoder decodeObjectForKey:@"diff"] retain];
        _filename = [[decoder decodeObjectForKey:@"filename"] retain];
    }
    return self;
}

@end
