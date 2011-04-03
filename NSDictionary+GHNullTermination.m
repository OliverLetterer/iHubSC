//
//  NSDictionary+GHNullTermination.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSDictionary+GHNullTermination.h"


@implementation NSDictionary (GHNullTermination)

- (id)objectForKeyOrNilOnNullObject:(id)aKey {
    id value = [self objectForKey:aKey];
    return [value isKindOfClass:[NSNull class]] ? nil : value;
}

@end
