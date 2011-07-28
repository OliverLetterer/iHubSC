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

@implementation UIViewController (GHViewControllerErrorhandling)

- (void)invalidadUserData {
    [GHAPIAuthenticationManager sharedInstance].authenticatedUser = nil;
}

- (void)handleError:(NSError *)error {
    if (error != nil) {
        DLog(@"%@", error);
        
        if (![GHAPIAuthenticationManager sharedInstance].authenticatedUser.login || [[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login isEqualToString:@""]) {
#warning change account here
            GHAuthenticationAlertView *alert = [[GHAuthenticationAlertView alloc] initWithDelegate:nil];
            [alert show];
            return;
        }
        
        if (error.code == 3) {
            // authentication needed
            [self invalidadUserData];
            #warning change account here
            GHAuthenticationAlertView *alert = [[GHAuthenticationAlertView alloc] initWithDelegate:nil];
            [alert show];
        } else {
            [[ANNotificationQueue sharedInstance] detatchErrorNotificationWithTitle:NSLocalizedString(@"Error", @"") 
                                                                       errorMessage:[error localizedDescription]];
        }
    }
}

@end
