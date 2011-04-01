//
//  GHCommitMessage.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitMessage.h"


@implementation GHCommitMessage

@synthesize head=_head, EMail=_EMail, message=_message, name=_name;

#pragma mark - Initialization

- (id)initWithRawArray:(NSArray *)array {
    if ((self = [super init]) && array) {
        // Initialization code
        NSAssert(array.count == 4, @"%s array must contain 4  objects, head, EMail, message, name", __PRETTY_FUNCTION__);
        self.head = [array objectAtIndex:0];
        self.EMail = [array objectAtIndex:1];
        self.message = [array objectAtIndex:2];
        self.name = [array objectAtIndex:3];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_head release];
    [_EMail release];
    [_message release];
    [_name release];
    [super dealloc];
}

@end
