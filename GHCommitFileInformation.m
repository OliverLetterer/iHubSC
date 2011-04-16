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
    if ((self = [super init])) {
        DLog(@"%@", rawDictionary);
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

@end
