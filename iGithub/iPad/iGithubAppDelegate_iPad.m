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
#warning check for reenable
//#if DEBUG
//    
////    [GHSettingsHelper setUsername:@"iTunesTestAccount"];
////    [GHSettingsHelper setPassword:@"iTunes1"];
//    
//    [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
//    [GHAPIAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
//#else
//    [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
//    [GHAPIAuthenticationManager sharedInstance].password = [GHSettingsHelper password];
//#endif
    
    NSMutableDictionary *dictionary = [self deserializeState];
    
    if (dictionary) {
        NSArray *rightViewControllers = [dictionary objectForKey:@"rightViewControllers"];  
        GHPLeftNavigationController *leftViewController = [dictionary objectForKey:@"leftViewController"];
        NSUInteger indexOfFrontViewController = [[dictionary objectForKey:@"indexOfFrontViewController"] unsignedIntegerValue];
        
        self.advancedNavigationController = [[ANAdvancedNavigationController alloc] initWithLeftViewController:leftViewController rightViewControllers:rightViewControllers];
        self.advancedNavigationController.delegate = self;
        self.advancedNavigationController.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.advancedNavigationController.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ANBackgroundImage.png"] ];
        self.advancedNavigationController.indexOfFrontViewController = indexOfFrontViewController;
    } else {
        GHPLeftNavigationController *leftViewController = [[GHPLeftNavigationController alloc] initWithStyle:UITableViewStyleGrouped];
        
        self.advancedNavigationController = [[ANAdvancedNavigationController alloc] initWithLeftViewController:leftViewController];
        self.advancedNavigationController.delegate = self;
        self.advancedNavigationController.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
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
