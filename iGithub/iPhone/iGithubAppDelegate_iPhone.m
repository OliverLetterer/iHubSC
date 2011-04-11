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

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController, repositoriesViewController=_repositoriesViewController;

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification {
    self.repositoriesViewController.username = [GHSettingsHelper username];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // build userInterface here
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(authenticationViewControllerdidAuthenticateUserCallback:) 
                                                 name:GHAuthenticationViewControllerDidAuthenticateUserNotification 
                                               object:nil];
    
#if DEBUG
    [GHSettingsHelper setUsername:@"docmorelli"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    [GHSettingsHelper setGravatarID:@"534296d28e4a7118d2e75e84d04d571e"];
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSMutableArray *tabBarItems = [NSMutableArray array];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    [self.window addSubview:self.tabBarController.view];
    
    self.newsFeedViewController = [[[GHNewsFeedViewController alloc] init] autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] autorelease] ];
    
    self.repositoriesViewController = [[[GHUserViewController alloc] initWithUsername:[GHAuthenticationManager sharedInstance].username] autorelease];
    self.repositoriesViewController.reloadDataIfNewUserGotAuthenticated = YES;
    self.repositoriesViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profil", @"") 
                                                                                image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                                  tag:0]
                                                  autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.repositoriesViewController] autorelease] ];
    
    self.tabBarController.viewControllers = tabBarItems;
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - memory management

- (void)dealloc {
    [_repositoriesViewController release];
    [_tabBarController release];
    [_newsFeedViewController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
