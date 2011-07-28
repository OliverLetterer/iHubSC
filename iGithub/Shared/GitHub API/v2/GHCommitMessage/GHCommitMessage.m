//
//  GHCommitMessage.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitMessage.h"
#import "GithubAPI.h"

@implementation GHCommitMessage

@synthesize head=_head, EMail=_EMail, message=_message, name=_name;

#pragma mark - Initialization

- (id)initWithRawArray:(NSArray *)array {
    array = GHAPIObjectExpectedClass(array, NSArray.class);
    if ((self = [super init]) && array) {
        // Initialization code
        self.head = [array objectAtIndex:0];
        self.EMail = [array objectAtIndex:1];
        self.message = [array objectAtIndex:2];
        self.name = [array objectAtIndex:3];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.EMail forKey:@"EMail"];
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.EMail = [aDecoder decodeObjectForKey:@"EMail"];
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
