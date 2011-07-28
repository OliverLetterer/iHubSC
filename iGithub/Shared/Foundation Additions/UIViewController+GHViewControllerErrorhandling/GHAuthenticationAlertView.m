//
//  GHAuthenticationAlertView.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAuthenticationAlertView.h"
#import "GithubAPI.h"

static BOOL _isAutheticationAlertViewVisible = NO;

@implementation GHAuthenticationAlertView

+ (id)allocWithZone:(NSZone *)zone {
    if (!_isAutheticationAlertViewVisible) {
        return [super allocWithZone:zone];
    }
    return nil;
}

- (id)initWithDelegate:(id)delegate showCancelButton:(BOOL)showCancelButton {
    _showCancelButton = showCancelButton;
    if (self = [super initWithTitle:NSLocalizedString(@"Login to GitHub", @"") message:nil delegate:delegate cancelButtonTitle:showCancelButton ? NSLocalizedString(@"Cancel", @"") : nil otherButtonTitles:NSLocalizedString(@"Login", @""), nil]) {
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
    if (!_hasAuthenticatedUser && (buttonIndex == 1 || !_showCancelButton)) {
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
                                         
                                         [[GHAPIAuthenticationManager sharedInstance] addAuthenticatedUser:user password:password];
                                     }
                                 }];
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
        _isAutheticationAlertViewVisible = NO;
    }
}

- (void)show {
    _isAutheticationAlertViewVisible = YES;
    [super show];
}

@end
