//
//  iGithubAppDelegate_iPhone.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGithubAppDelegate.h"
#import "GHAuthenticationViewController.h"
#import "GHNewsFeedViewController.h"
#import "GHRepositoriesViewController.h"

@interface iGithubAppDelegate_iPhone : iGithubAppDelegate <GHAuthenticationViewControllerDelegate> {
    UITabBarController *_tabBarController;
    GHNewsFeedViewController *_newsFeedViewController;
    GHRepositoriesViewController *_repositoriesViewController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) GHNewsFeedViewController *newsFeedViewController;
@property (nonatomic, retain) GHRepositoriesViewController *repositoriesViewController;

@end
