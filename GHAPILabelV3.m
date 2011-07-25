//
//  GHAPILabelV3.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPILabelV3.h"
#import "GithubAPI.h"

@implementation GHAPILabelV3

@synthesize URL=_URL, name=_name, colorString=_colorString;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.colorString = [rawDictionary objectForKeyOrNilOnNullObject:@"color"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_name release];
    [_colorString release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_colorString forKey:@"colorString"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _colorString = [[decoder decodeObjectForKey:@"colorString"] retain];
    }
    return self;
}

@end
