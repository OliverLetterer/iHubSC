//
//  GHAuthenticationAlertView.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHAuthenticationAlertView;

@interface GHAuthenticationAlertView : UIAlertView {
@private
    BOOL _hasAuthenticatedUser;
    BOOL _showCancelButton;
}

- (id)initWithDelegate:(id)delegate showCancelButton:(BOOL)showCancelButton;

- (void)setLoginButtonEnabled:(BOOL)enabled;

@end
