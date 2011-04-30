//
//  GHTableViewControllerAlertViewProxy.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewControllerAlertViewProxy.h"


@implementation GHTableViewControllerAlertViewProxy

@synthesize delegate=_delegate, alert=_alert;

#pragma mark - Initialization

- (id)initWithAlertView:(UIAlertView *)alertView delegate:(id<GHTableViewControllerAlertViewProxyDelegate>)delegate {
    if ((self = [super init])) {
        // Initialization code
        self.alert = alertView;
        alertView.delegate = self;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_alert release];
    
    [super dealloc];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.delegate alertViewProxy:self alertView:alertView clickedButtonAtIndex:buttonIndex];
}

@end
