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
        [_alertProxy release];
        _alertProxy = [alertProxy retain];
    }
}

- (GHTableViewControllerAlertViewProxy *)alertProxy {
    return _alertProxy;
}

#pragma mark - GHTableViewControllerAlertViewProxyDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"wow, ive received a button !!!");
}

@end
