//
//  GHPOwnersNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOwnersNewsFeedViewController.h"


@implementation GHPOwnersNewsFeedViewController

#pragma mark - initialization

- (id)init {
    if (self = [super init]) {
        self.reloadDataOnApplicationWillEnterForeground = YES;
        self.reloadDataIfNewUserGotAuthenticated = YES;
    }
    return self;
}

#pragma mark - Downloading

- (void)downloadNewsFeed {
    [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
        }
    }];
}

@end
