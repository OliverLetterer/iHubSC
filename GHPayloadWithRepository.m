//
//  GHPayloadWithRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayloadWithRepository.h"


@implementation GHPayloadWithRepository

@synthesize repo=_repo;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.repo = [rawDictionary objectForKey:@"repo"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repo release];
    [super dealloc];
}

@end
