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

@synthesize tabBarController=_tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // build userInterface here
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    [self.window addSubview:self.tabBarController.view];
    
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
	[super dealloc];
}

@end
