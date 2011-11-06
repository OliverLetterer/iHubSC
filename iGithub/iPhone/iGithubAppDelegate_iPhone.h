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
#import "GHOwnersNeedsFeedViewController.h"
#import "GHUserViewController.h"
#import "GHSearchViewController.h"
#import "GHAuthenticatedUserViewController.h"
#import "GHIssuesOfAuthenticatedUserViewController.h"

@interface iGithubAppDelegate_iPhone : iGithubAppDelegate <MFMailComposeViewControllerDelegate> {
    UITabBarController *_tabBarController;
    GHOwnersNeedsFeedViewController *_newsFeedViewController;
    GHAuthenticatedUserViewController *_profileViewController;
    GHSearchViewController *_searchViewController;
    GHIssuesOfAuthenticatedUserViewController *_issuesOfUserViewController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) GHOwnersNeedsFeedViewController *newsFeedViewController;
@property (nonatomic, retain) GHAuthenticatedUserViewController *profileViewController;
@property (nonatomic, retain) GHSearchViewController *searchViewController;
@property (nonatomic, retain) GHIssuesOfAuthenticatedUserViewController *issuesOfUserViewController;


- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification;

@end
