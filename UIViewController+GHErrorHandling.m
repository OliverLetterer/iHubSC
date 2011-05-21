//
//  UIViewController+GHErrorHandling.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIViewController+GHErrorHandling.h"
#import "GHAuthenticationManager.h"
#import "GHSettingsHelper.h"

@implementation UIViewController (GHViewControllerErrorhandling)

- (void)invalidadUserData {
    [GHSettingsHelper setPassword:nil];
    [GHSettingsHelper setGravatarID:nil];
    [GHSettingsHelper setUsername:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GHAuthenticationManager sharedInstance].username = nil;
    [GHAuthenticationManager sharedInstance].password = nil;
}

- (void)handleError:(NSError *)error {
    if (error != nil) {
        DLog(@"%@", error);
        
        if (![GHAuthenticationManager sharedInstance].username || [[GHAuthenticationManager sharedInstance].username isEqualToString:@""]) {
            [self invalidadUserData];
            GHAuthenticationViewController *authViewController = [[[GHAuthenticationViewController alloc] init] autorelease];
            authViewController.delegate = self;
            
            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:authViewController] autorelease];
            
            [self presentModalViewController:navController animated:YES];
            return;
        }
        
        if (error.code == 3) {
            // authentication needed
            if (![GHAuthenticationViewController isOneAuthenticationViewControllerActive]) {
                [self invalidadUserData];
                GHAuthenticationViewController *authViewController = [[[GHAuthenticationViewController alloc] init] autorelease];
                authViewController.delegate = self;
                
                UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:authViewController] autorelease];
                
                [self presentModalViewController:navController animated:YES];
            }
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                             message:[error localizedDescription] 
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                   otherButtonTitles:nil]
                                  autorelease];
            [alert show];
        }
    }
}

#pragma mark - GHAuthenticationViewControllerDelegate

- (void)authenticationViewController:(GHAuthenticationViewController *)authenticationViewController didAuthenticateUser:(GHAPIUserV3 *)user {
    [self dismissModalViewControllerAnimated:YES];
}

@end
