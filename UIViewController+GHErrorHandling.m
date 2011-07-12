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
#import "GHAuthenticationAlertView.h"
#import "ANNotificationQueue.h"

@implementation UIViewController (GHViewControllerErrorhandling)

- (void)invalidadUserData {
    [GHSettingsHelper setPassword:nil];
    [GHSettingsHelper setAvatarURL:nil];
    [GHSettingsHelper setUsername:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GHAuthenticationManager sharedInstance].username = nil;
    [GHAuthenticationManager sharedInstance].password = nil;
}

- (void)handleError:(NSError *)error {
    if (error != nil) {
        DLog(@"%@", error);
        
        if (![GHAuthenticationManager sharedInstance].username || [[GHAuthenticationManager sharedInstance].username isEqualToString:@""]) {
            GHAuthenticationAlertView *alert = [[[GHAuthenticationAlertView alloc] initWithDelegate:nil] autorelease];
            [alert show];
            return;
        }
        
        if (error.code == 3) {
            // authentication needed
            [self invalidadUserData];
            GHAuthenticationAlertView *alert = [[[GHAuthenticationAlertView alloc] initWithDelegate:nil] autorelease];
            [alert show];
        } else {
            [[ANNotificationQueue sharedInstance] detatchErrorNotificationWithTitle:NSLocalizedString(@"Error", @"") 
                                                                       errorMessage:[error localizedDescription]];
        }
    }
}

@end
