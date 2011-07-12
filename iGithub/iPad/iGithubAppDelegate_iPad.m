//
//  iGithubAppDelegate_iPad.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate_iPad.h"
#import "GHPLeftNavigationController.h"
#import "ANAdvancedNavigationController.h"
#import "INNotificationQueue.h"
#import "GHSettingsHelper.h"
#import "GHAuthenticationManager.h"
#import "GHPSearchScopeTableViewCell.h"

@implementation iGithubAppDelegate_iPad

- (void)setupAppearences {
    // Buttons in GHPSearchScopeTableViewCell
    
    id proxy = [UIButton appearanceWhenContainedIn:[GHPSearchScopeTableViewCell class], nil];
    
    [proxy setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [proxy setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [proxy setBackgroundImage:[[UIImage imageNamed:@"GHPSelectedBackgroundImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)] forState:UIControlStateHighlighted];
    [proxy setBackgroundImage:[[UIImage imageNamed:@"GHPSelectedBackgroundImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)] forState:UIControlStateSelected];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppearences];
#if DEBUG
    [GHSettingsHelper setUsername:@"docmorelli"];
    [GHSettingsHelper setPassword:@"1337-l0g1n"];
    
    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
    [GHSettingsHelper setPassword:@"iTunes1"];
    
    [GHSettingsHelper setAvatarURL:@"https://secure.gravatar.com/avatar/534296d28e4a7118d2e75e84d04d571e?s=140&d=https://gs1.wac.edgecastcdn.net/80460E/assets%2Fimages%2Fgravatars%2Fgravatar-140.png"];
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#else
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    GHPLeftNavigationController *testVC = [[[GHPLeftNavigationController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        
    ANAdvancedNavigationController *controller = [[[ANAdvancedNavigationController alloc] initWithLeftViewController:testVC] autorelease];
    controller.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    controller.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ANBackgroundImage.png"] ];
    
    [INNotificationQueue sharedQueue].notificationView = controller.view;
    [INNotificationQueue sharedQueue].notificationCenterPoint = CGPointMake(controller.view.bounds.size.width/2.0f, controller.view.bounds.size.height/2.0f);
    
    self.window.rootViewController = controller;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotificationCallback:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)deviceOrientationDidChangeNotificationCallback:(NSNotification *)notification {
    UIViewController *controller = self.window.rootViewController;
    
    [INNotificationQueue sharedQueue].notificationView = controller.view;
    [INNotificationQueue sharedQueue].notificationCenterPoint = CGPointMake(controller.view.bounds.size.width/2.0f, controller.view.bounds.size.height/2.0f);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
