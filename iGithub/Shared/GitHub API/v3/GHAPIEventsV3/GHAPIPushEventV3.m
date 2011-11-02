//
//  GHAPIPushEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIPushEventV3
@synthesize head=_head, ref=_ref, numberOfCommits=_numberOfCommits, commits=_commits;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        _ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        _numberOfCommits = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"pages"];
        GHAPIObjectExpectedClass(&rawArray, NSArray.class);
        
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[GHAPICommitV3 alloc] initWithRawDictionary:obj] ];
        }];
        
        _commits = finalArray;
    }
    return self;
}

@end
