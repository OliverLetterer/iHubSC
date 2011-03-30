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

@interface iGithubAppDelegate_iPhone : iGithubAppDelegate <GHAuthenticationViewControllerDelegate> {
    UITabBarController *_tabBarController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;

@end
