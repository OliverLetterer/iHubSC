//
//  GHTableViewController+private.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewController+private.h"


@implementation GHTableViewController (GHTableViewControllerPrivate)

- (void)setAlertProxy:(GHTableViewControllerAlertViewProxy *)alertProxy {
    if (alertProxy != _alertProxy) {
        _alertProxy = alertProxy;
    }
}

- (GHTableViewControllerAlertViewProxy *)alertProxy {
    return _alertProxy;
}

#pragma mark - GHTableViewControllerAlertViewProxyDelegate

- (void)alertViewProxy:(GHTableViewControllerAlertViewProxy *)proxy 
             alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        // user wants to change his account
        [self invalidadUserData];
        [self handleError:[NSError errorWithDomain:@"" code:3 userInfo:nil] ];
    }
    
    self.alertProxy = nil;
}

@end
