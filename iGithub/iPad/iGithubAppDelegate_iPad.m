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
#import "GHSettingsHelper.h"
#import "GHAPIAuthenticationManager.h"
#import "GHPSearchScopeTableViewCell.h"

@implementation iGithubAppDelegate_iPad

@synthesize advancedNavigationController=_advancedNavigationController;

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
    
//    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
//    [GHSettingsHelper setPassword:@"iTunes1"];
    
    [GHSettingsHelper setAvatarURL:@"https://secure.gravatar.com/avatar/534296d28e4a7118d2e75e84d04d571e?s=140&d=https://gs1.wac.edgecastcdn.net/80460E/assets%2Fimages%2Fgravatars%2Fgravatar-140.png"];
    [GHAPIAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAPIAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#else
    [GHAuthenticationManager sharedInstance].username = [GHSettingsHelper username];
    [GHAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
#endif
    
    NSMutableDictionary *dictionary = [self deserializeState];
    
    if (dictionary) {
        NSArray *rightViewControllers = [dictionary objectForKey:@"rightViewControllers"];  
        GHPLeftNavigationController *leftViewController = [dictionary objectForKey:@"leftViewController"];
        NSUInteger indexOfFrontViewController = [[dictionary objectForKey:@"indexOfFrontViewController"] unsignedIntegerValue];
        
        self.advancedNavigationController = [[[ANAdvancedNavigationController alloc] initWithLeftViewController:leftViewController rightViewControllers:rightViewControllers] autorelease];
        self.advancedNavigationController.delegate = self;
        self.advancedNavigationController.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.advancedNavigationController.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ANBackgroundImage.png"] ];
        self.advancedNavigationController.indexOfFrontViewController = indexOfFrontViewController;
    } else {
        GHPLeftNavigationController *leftViewController = [[[GHPLeftNavigationController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        
        self.advancedNavigationController = [[[ANAdvancedNavigationController alloc] initWithLeftViewController:leftViewController] autorelease];
        self.advancedNavigationController.delegate = self;
        self.advancedNavigationController.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.advancedNavigationController.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ANBackgroundImage.png"] ];
    }
    
    self.window.rootViewController = self.advancedNavigationController;
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_advancedNavigationController.delegate == self) {
        _advancedNavigationController.delegate = nil;
    }
    [_advancedNavigationController release];
    
	[super dealloc];
}

#pragma mark - Serialization

- (NSMutableDictionary *)serializedStateDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [dictionary setObject:self.advancedNavigationController.leftViewController forKey:@"leftViewController"];
    [dictionary setObject:self.advancedNavigationController.rightViewControllers forKey:@"rightViewControllers"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.advancedNavigationController.indexOfFrontViewController] forKey:@"indexOfFrontViewController"];
    
    return dictionary;
}

#pragma mark - ANAdvancedNavigationControllerDelegate

- (void)advancedNavigationController:(ANAdvancedNavigationController *)navigationController willPopToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[GHTableViewController class]]) {
        GHTableViewController *tableViewController = (GHTableViewController *)viewController;
        [tableViewController.tableView deselectRowAtIndexPath:tableViewController.tableView.indexPathForSelectedRow animated:animated];
    }
}

@end
