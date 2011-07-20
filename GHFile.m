//
//  GHFile.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFile.h"


@implementation GHFile

@synthesize hash=_hash;

- (GHFileSystemItemType)type {
    [self doesNotRecognizeSelector:_cmd];
    return GHFileSystemItemTypeFile;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@", self.name, self.hash];
}

- (NSComparisonResult)caseInsensitiveCompare:(GHFile *)aFile {
    return [self.name caseInsensitiveCompare:aFile.name];
}

#pragma mark - Initialization

- (id)initWithName:(NSString *)name hash:(NSString *)hash {
    if ((self = [super init])) {
        self.name = name;
        self.hash = hash;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_hash release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hash forKey:@"hash"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _hash = [[decoder decodeObjectForKey:@"hash"] retain];
    }
    return self;
}

@end
