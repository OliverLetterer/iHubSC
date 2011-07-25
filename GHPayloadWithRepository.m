//
//  GHPayloadWithRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayloadWithRepository.h"
#import "GithubAPI.h"

@implementation GHPayloadWithRepository

@synthesize repository=_repository;

- (NSString *)repo {
    return self.repository.fullName;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repository"]] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.repository forKey:@"repository"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.repository = [aDecoder decodeObjectForKey:@"repository"];
    }
    return self;
}

@end
