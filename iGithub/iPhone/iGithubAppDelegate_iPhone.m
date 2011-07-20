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

#define kLastKnownApplicationStateFileName @"de.olettere.lastKnownApplicationState.plist"

@implementation iGithubAppDelegate_iPhone

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController, profileViewController=_profileViewController, searchViewController=_searchViewController;

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
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
                                             selector:@selector(authenticationManagerDidAuthenticateUserCallback:) 
                                                 name:GHAuthenticationManagerDidAuthenticateNewUserNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(unknownPayloadEventTypeCallback:) 
                                                 name:@"GHUnknownPayloadEventType" 
                                               object:nil];
    
#if DEBUG
    [GHSettingsHelper setUsername:@"docmorelli"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    
//    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
//    [GHSettingsHelper setPassword:@"iTunes1"];
    
    [GHSettingsHelper setAvatarURL:@"https://secure.gravatar.com/avatar/534296d28e4a7118d2e75e84d04d571e?s=140&d=https://gs1.wac.edgecastcdn.net/80460E/assets%2Fimages%2Fgravatars%2Fgravatar-140.png"];
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#else
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kLastKnownApplicationStateFileName];
    
    NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
//    tabBarController = nil;
    if (dictionary) {
        self.tabBarController = [[[UITabBarController alloc] init] autorelease];
        self.window.rootViewController = self.tabBarController;
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:3];
        
        NSArray *viewControllers0 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:0]];
        NSArray *viewControllers1 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:1]];
        NSArray *viewControllers2 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:2]];
        
        UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
        [navigationController setViewControllers:viewControllers0 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[[UINavigationController alloc] init] autorelease];
        [navigationController setViewControllers:viewControllers1 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[[UINavigationController alloc] init] autorelease];
        [navigationController setViewControllers:viewControllers2 animated:NO];
        [viewControllers addObject:navigationController];
        
        self.tabBarController.viewControllers = viewControllers;
        self.tabBarController.selectedIndex = [[dictionary objectForKey:@"self.tabBarController.selectedIndex"] unsignedIntegerValue];
        
        self.newsFeedViewController = [viewControllers0 objectAtIndex:0];
        self.profileViewController = [viewControllers1 objectAtIndex:0];
        self.searchViewController = [viewControllers2 objectAtIndex:0];
        
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    } else {
        NSMutableArray *tabBarItems = [NSMutableArray array];
        
        self.tabBarController = [[[UITabBarController alloc] init] autorelease];
        self.window.rootViewController = self.tabBarController;
        
        self.newsFeedViewController = [[[GHOwnerNewsFeedViewController alloc] init] autorelease];
        [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] autorelease] ];
        
        self.profileViewController = [[[GHUserViewController alloc] initWithUsername:[GHAuthenticationManager sharedInstance].username] autorelease];
        self.profileViewController.reloadDataIfNewUserGotAuthenticated = YES;
        self.profileViewController.pullToReleaseEnabled = YES;
        [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.profileViewController] autorelease] ];
        
        self.searchViewController = [[[GHSearchViewController alloc] init] autorelease];
        [tabBarItems addObject:[[[UINavigationController alloc] initWithRootViewController:self.searchViewController] autorelease] ];
        
        self.tabBarController.viewControllers = tabBarItems;
    }
    
    self.profileViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0]
                                             autorelease];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - UIApplicationDelegate

//- (void)applicationWillTerminate:(UIApplication *)application {
//    [super applicationWillTerminate:application];
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kLastKnownApplicationStateFileName];
//    
//    [NSKeyedArchiver archiveRootObject:self.tabBarController toFile:filePath];
//}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [super applicationDidEnterBackground:application];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kLastKnownApplicationStateFileName];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.tabBarController.selectedIndex] forKey:@"self.tabBarController.selectedIndex"];
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UINavigationController *navController = obj;
        [dictionary setObject:navController.viewControllers forKey:[NSNumber numberWithUnsignedInteger:idx]];
    }];
    
    DLog(@"%d", [NSKeyedArchiver archiveRootObject:dictionary toFile:filePath]);
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
