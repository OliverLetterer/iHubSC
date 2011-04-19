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

@end
