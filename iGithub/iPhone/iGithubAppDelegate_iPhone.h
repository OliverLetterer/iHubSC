//
//  iGithubAppDelegate_iPhone.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGithubAppDelegate.h"
#import "GHNewsFeedViewController.h"
#import "GHUserViewController.h"

@interface iGithubAppDelegate_iPhone : iGithubAppDelegate {
    UITabBarController *_tabBarController;
    GHNewsFeedViewController *_newsFeedViewController;
    GHUserViewController *_repositoriesViewController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) GHNewsFeedViewController *newsFeedViewController;
@property (nonatomic, retain) GHUserViewController *repositoriesViewController;

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification;

@end
