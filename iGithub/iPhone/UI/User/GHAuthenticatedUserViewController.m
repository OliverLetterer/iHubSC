//
//  GHAuthenticatedUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAuthenticatedUserViewController.h"
#import "GHManageAuthenticatedUsersAlertView.h"

@implementation GHAuthenticatedUserViewController

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithUsername:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ])) {
        self.reloadDataIfNewUserGotAuthenticated = YES;
        self.pullToReleaseEnabled = YES;
    }
    return self;
}

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    [super authenticationManagerDidAuthenticateUserCallback:notification];
    self.username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
}

#pragma mark - target actions

- (void)accountButtonClicked:(UIBarButtonItem *)button {
    GHManageAuthenticatedUsersAlertView *alert = [[GHManageAuthenticatedUsersAlertView alloc] initWithTitle:nil 
                                                                                                    message:nil 
                                                                                                   delegate:nil 
                                                                                          cancelButtonTitle:nil 
                                                                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accounts", @"") 
                                                                             style:UIBarButtonItemStyleBordered 
                                                                            target:self action:@selector(accountButtonClicked:)];
}

@end
