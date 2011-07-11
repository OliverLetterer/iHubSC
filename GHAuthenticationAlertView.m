//
//  GHAuthenticationAlertView.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAuthenticationAlertView.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"

@implementation GHAuthenticationAlertView

- (id)initWithDelegate:(id)delegate {
    if (self = [super initWithTitle:NSLocalizedString(@"Login to GitHub", @"") message:nil delegate:delegate cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Login", @""), nil]) {
        // Initialization code here.
        self.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    return self;
}

- (void)setLoginButtonEnabled:(BOOL)enabled {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.userInteractionEnabled = enabled;
            view.alpha = 0.25f + 0.75f * (CGFloat)enabled;
        }
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (!_hasAuthenticatedUser) {
        [self setLoginButtonEnabled:NO];
        NSString *username = [self textFieldAtIndex:0].text;
        NSString *password = [self textFieldAtIndex:1].text;
        [GHAPIUserV3 authenticatedUserWithUsername:username password:password 
                                 completionHandler:^(GHAPIUserV3 *user, NSError *error) {
                                     [self setLoginButtonEnabled:YES];
                                     if (error) {
                                         self.title = NSLocalizedString(@"Invalid Authentication", @"");
                                     } else {
                                         _hasAuthenticatedUser = YES;
                                         [self dismissWithClickedButtonIndex:0 animated:YES];
                                         
                                         [GHSettingsHelper setUsername:user.login];
                                         [GHSettingsHelper setPassword:password];
                                         [GHSettingsHelper setGravatarID:user.gravatarID];
                                         
                                         [[GHAuthenticationManager sharedInstance] saveAuthenticatedUserWithName:user.login 
                                                                                                        password:password];
                                         
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                     }
                                 }];
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
}

@end
