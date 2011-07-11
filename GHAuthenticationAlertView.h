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
}

- (id)initWithDelegate:(id)delegate;

- (void)setLoginButtonEnabled:(BOOL)enabled;

@end
