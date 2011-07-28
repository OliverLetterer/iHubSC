//
//  UIViewController+GHErrorHandling.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIViewController+GHErrorHandling.h"
#import "GHAPIAuthenticationManager.h"
#import "GHAuthenticationAlertView.h"
#import "ANNotificationQueue.h"
#import "GHManageAuthenticatedUsersAlertView.h"

@implementation UIViewController (GHViewControllerErrorhandling)

- (void)invalidadUserData {
    [GHAPIAuthenticationManager sharedInstance].authenticatedUser = nil;
}

- (void)handleError:(NSError *)error {
    if (error != nil) {
        DLog(@"%@", error);
        
        if (![GHAPIAuthenticationManager sharedInstance].authenticatedUser) {
            GHAuthenticationAlertView *alert = [[GHAuthenticationAlertView alloc] initWithDelegate:nil showCancelButton:NO];
            [alert show];
            return;
        }
        
        if (error.code == 3) {
            // authentication needed
            [self invalidadUserData];
            GHManageAuthenticatedUsersAlertView *alert = [[GHManageAuthenticatedUsersAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alert show];
        } else {
            [[ANNotificationQueue sharedInstance] detatchErrorNotificationWithTitle:NSLocalizedString(@"Error", @"") 
                                                                       errorMessage:[error localizedDescription]];
        }
    }
}

@end
