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
#import "INNotificationQueue.h"
#import "GHAuthenticationAlertView.h"

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

@end
