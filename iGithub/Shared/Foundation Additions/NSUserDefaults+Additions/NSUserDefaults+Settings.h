//
//  NSUserDefaults+Settings.h
//  iGithub
//
//  Created by Oliver Letterer on 04.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const GHIssuesOfAuthenticatedUsersShowBadgeKey;

@interface NSUserDefaults (Settings)

@property (nonatomic, readonly) BOOL showIssuesBadge;

@end
