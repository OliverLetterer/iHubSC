//
//  iGithubAppDelegate_iPad.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate_iPad.h"
#import "GHPTableViewController.h"
#import "GHPLeftNavigationController.h"
#import "ANAdvancedNavigationController.h"

@implementation iGithubAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GHPLeftNavigationController *testVC = [[[GHPLeftNavigationController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        
    ANAdvancedNavigationController *controller = [[[ANAdvancedNavigationController alloc] initWithLeftViewController:testVC] autorelease];
    controller.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    controller.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ANBackgroundImage.png"] ];
    
    self.window.rootViewController = controller;

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)dealloc
{
	[super dealloc];
}

@end
