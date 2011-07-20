//
//  iGithubAppDelegate_iPhone.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

#import "iGithubAppDelegate.h"
#import "GHOwnerNewsFeedViewController.h"
#import "GHUserViewController.h"
#import "GHSearchViewController.h"

#warning save expansion states
#warning update default.pngs (make 2 new defaults)

@interface iGithubAppDelegate_iPhone : iGithubAppDelegate <MFMailComposeViewControllerDelegate> {
    UITabBarController *_tabBarController;
    GHOwnerNewsFeedViewController *_newsFeedViewController;
    GHUserViewController *_profileViewController;
    GHSearchViewController *_searchViewController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) GHOwnerNewsFeedViewController *newsFeedViewController;
@property (nonatomic, retain) GHUserViewController *profileViewController;
@property (nonatomic, retain) GHSearchViewController *searchViewController;

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification;

@end
