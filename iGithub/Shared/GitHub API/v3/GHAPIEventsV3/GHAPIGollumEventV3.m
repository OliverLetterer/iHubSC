//
//  GHAPIGollumEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIGollumEventV3
@synthesize pages=_pages;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        NSArray *rawPages = [rawDictionary objectForKeyOrNilOnNullObject:@"pages"];
        GHAPIObjectExpectedClass(&rawPages, NSArray.class);
        
        NSMutableArray *pages = [NSMutableArray arrayWithCapacity:rawPages.count];
        [rawPages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [pages addObject:[[GHAPIGollumPageV3 alloc] initWithRawDictionary:obj] ];
        }];
        
        _pages = pages;
    }
    return self;
}

@end
