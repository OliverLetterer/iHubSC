//
//  NSError+GithubAPI.m
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSError+GithubAPI.h"


@implementation NSError (GHGithubAPIAddition)

+ (NSError *)errorFromRawDictionary:(NSDictionary *)rawDictionary {
    
    NSString *errorString = [rawDictionary objectForKey:@"error"];
    
    if (errorString) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:errorString forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:@"de.olettere.GithubAPI" code:0 userInfo:userInfo];
    }
    
    return nil;
}

@end
