//
//  iGithubAppDelegate_iPhone.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate_iPhone.h"
#import "GHSettingsHelper.h"
#import "GithubAPI.h"

@implementation iGithubAppDelegate_iPhone

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // build userInterface here
    
#if DEBUG
    [GHSettingsHelper setUsername:@"docmorelli"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSMutableArray *tabBarItems = [NSMutableArray array];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    [self.window addSubview:self.tabBarController.view];
    
    self.newsFeedViewController = [[[GHNewsFeedViewController alloc] init] autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] autorelease] ];
    
    
    self.tabBarController.viewControllers = tabBarItems;
    
    
    if (![GHSettingsHelper isUserAuthenticated]) {
        GHAuthenticationViewController *authViewController = [[[GHAuthenticationViewController alloc] init] autorelease];
        authViewController.delegate = self;
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:authViewController] autorelease];
        [self.tabBarController presentModalViewController:navigationController animated:YES];
    }
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - GHAuthenticationViewControllerDelegate

- (void)authenticationViewController:(GHAuthenticationViewController *)authenticationViewController didAuthenticateUser:(GHUser *)user {
    [GHSettingsHelper setUsername:user.login];
    [GHSettingsHelper setPassword:user.password];
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

#pragma mark - memory management

- (void)dealloc
{
    [_tabBarController release];
    [_newsFeedViewController release];
	[super dealloc];
}

@end
