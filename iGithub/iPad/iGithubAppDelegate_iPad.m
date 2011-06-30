//
//  iGithubAppDelegate_iPad.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate_iPad.h"
#import "GHPTableViewController.h"

@implementation iGithubAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GHPTableViewController *tVC = [[[GHPTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    self.window.rootViewController = tVC;
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)dealloc
{
	[super dealloc];
}

@end
