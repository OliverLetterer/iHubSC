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
#import "INNotificationQueue.h"

@implementation iGithubAppDelegate_iPhone

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController, profileViewController=_profileViewController, searchViewController=_searchViewController;

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification {
    self.profileViewController.username = [GHSettingsHelper username];
    
    self.profileViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0]
                                             autorelease];
}

- (void)unknownPayloadEventTypeCallback:(NSNotification *)notification {
    MFMailComposeViewController* controller = [[[MFMailComposeViewController alloc] init] autorelease];
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
                                             selector:@selector(authenticationViewControllerdidAuthenticateUserCallback:) 
                                                 name:GHAuthenticationViewControllerDidAuthenticateUserNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(unknownPayloadEventTypeCallback:) 
                                                 name:@"GHUnknownPayloadEventType" 
                                               object:nil];
    
    [INNotificationQueue sharedQueue].notificationCenterPoint = CGPointMake(self.window.frame.size.width/2, self.window.frame.size.height/3);
	[INNotificationQueue sharedQueue].notificationView = self.window;
    
#if DEBUG
    [GHSettingsHelper setUsername:@"docmorelli"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    
//    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
//    [GHSettingsHelper setPassword:@"iTunes1"];
    
    [GHSettingsHelper setGravatarID:@"534296d28e4a7118d2e75e84d04d571e"];
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#else
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSMutableArray *tabBarItems = [NSMutableArray array];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    [self.window addSubview:self.tabBarController.view];
    
    self.newsFeedViewController = [[[GHOwnerNewsFeedViewController alloc] init] autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] autorelease] ];
    
    self.profileViewController = [[[GHUserViewController alloc] initWithUsername:[GHAuthenticationManager sharedInstance].username] autorelease];
    self.profileViewController.reloadDataIfNewUserGotAuthenticated = YES;
    self.profileViewController.pullToReleaseEnabled = YES;
    self.profileViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                                image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                                  tag:0]
                                                  autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.profileViewController] autorelease] ];
    
    self.searchViewController = [[[GHSearchViewController alloc] init] autorelease];
    [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.searchViewController] autorelease] ];
    
    self.tabBarController.viewControllers = tabBarItems;
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - memory management

- (void)dealloc {
    [_profileViewController release];
    [_tabBarController release];
    [_newsFeedViewController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
