//
//  NSError+GithubAPI.m
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSError+GithubAPI.h"
#import "GithubAPI.h"

@implementation NSError (GHGithubAPIAddition)

+ (NSError *)errorFromRawDictionary:(NSDictionary *)rawDictionary {
    
    if (![[rawDictionary class] isSubclassOfClass:[NSDictionary class] ]) {
        return nil;
    }
    
    NSString *errorString = [rawDictionary objectForKeyOrNilOnNullObject:@"error"];
    
    if (!errorString) {
        if ([rawDictionary allKeys].count == 1) {
            errorString = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
        }
    }
    
    if (errorString) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:errorString forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:@"de.olettere.GithubAPI" code:0 userInfo:userInfo];
    }
    
    return nil;
}

@end
