//
//  GHPNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPTableViewController.h"
#import "GithubAPI.h"

@interface GHPNewsFeedViewController : GHPTableViewController {
@private
    GHNewsFeed *_newsFeed;
}

@property (nonatomic, retain) GHNewsFeed *newsFeed;

@end
