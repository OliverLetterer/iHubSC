//
//  NSUserDefaults+Settings.m
//  iGithub
//
//  Created by Oliver Letterer on 04.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSUserDefaults+Settings.h"

NSString *const GHIssuesOfAuthenticatedUsersShowBadgeKey = @"GHIssuesOfAuthenticatedUsersShowBadge";



@implementation NSUserDefaults (Settings)

- (BOOL)showIssuesBadge {
    NSNumber *boolNumber = [self objectForKey:GHIssuesOfAuthenticatedUsersShowBadgeKey];
    if (!boolNumber) {
        return YES;
    }
    return [self boolForKey:GHIssuesOfAuthenticatedUsersShowBadgeKey];
}

@end
