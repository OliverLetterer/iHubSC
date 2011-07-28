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

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController, profileViewController=_profileViewController, searchViewController=_searchViewController;

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    self.profileViewController.username = [GHSettingsHelper username];
    
    self.profileViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0];
}

- (void)unknownPayloadEventTypeCallback:(NSNotification *)notification {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Unkown Event Type found"];
    [controller setMessageBody:[[notification userInfo] description] isHTML:NO]; 
    [self.tabBarController presentModalViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // build userInterface here
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(authenticationManagerDidAuthenticateUserCallback:) 
                                                 name:GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(unknownPayloadEventTypeCallback:) 
                                                 name:@"GHUnknownPayloadEventType" 
                                               object:nil];
    
#if DEBUG
    [GHSettingsHelper setUsername:@"OliverLetterer"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    
//    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
//    [GHSettingsHelper setPassword:@"iTunes1"];
    
    [GHSettingsHelper setAvatarURL:@"http://www.gravatar.com/avatar/5ba61d83fd609c878b116cfc4328b65c?s=80"];
    [GHAPIAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAPIAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#else
    [GHAPIAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAPIAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSMutableDictionary *dictionary = [self deserializeState];
    
    if (dictionary) {
        self.tabBarController = [[UITabBarController alloc] init];
        self.window.rootViewController = self.tabBarController;
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:3];
        
        NSArray *viewControllers0 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:0]];
        NSArray *viewControllers1 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:1]];
        NSArray *viewControllers2 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:2]];
        
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers0 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers1 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers2 animated:NO];
        [viewControllers addObject:navigationController];
        
        self.tabBarController.viewControllers = viewControllers;
        self.tabBarController.selectedIndex = [[dictionary objectForKey:@"self.tabBarController.selectedIndex"] unsignedIntegerValue];
        
        self.newsFeedViewController = [viewControllers0 objectAtIndex:0];
        self.profileViewController = [viewControllers1 objectAtIndex:0];
        self.searchViewController = [viewControllers2 objectAtIndex:0];
    } else {
        NSMutableArray *tabBarItems = [NSMutableArray array];
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.window.rootViewController = self.tabBarController;
        
        self.newsFeedViewController = [[GHOwnerNewsFeedViewController alloc] init];
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] ];
        
        self.profileViewController = [[GHUserViewController alloc] initWithUsername:[GHAPIAuthenticationManager sharedInstance].username];
        self.profileViewController.reloadDataIfNewUserGotAuthenticated = YES;
        self.profileViewController.pullToReleaseEnabled = YES;
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.profileViewController] ];
        
        self.searchViewController = [[GHSearchViewController alloc] init];
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.searchViewController] ];
        
        self.tabBarController.viewControllers = tabBarItems;
    }
    
    self.profileViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - Serialization

- (NSMutableDictionary *)serializedStateDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.tabBarController.selectedIndex] forKey:@"self.tabBarController.selectedIndex"];
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UINavigationController *navController = obj;
        [dictionary setObject:navController.viewControllers forKey:[NSNumber numberWithUnsignedInteger:idx]];
    }];
    
    return dictionary;
}

#pragma mark - memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
