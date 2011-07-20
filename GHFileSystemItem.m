//
//  GHFileSystemItem.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFileSystemItem.h"


@implementation GHFileSystemItem

@synthesize name=_name;

- (GHFileSystemItemType)type {
    [self doesNotRecognizeSelector:_cmd];
    return GHFileSystemItemTypeFile;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        // Initialization code
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [[decoder decodeObjectForKey:@"name"] retain];
    }
    return self;
}

@end
