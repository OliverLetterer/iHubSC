//
//  GHPUsersNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPUsersNewsFeedViewController.h"


@implementation GHPUsersNewsFeedViewController

@synthesize username=_username;

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super init])) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - Downloading

- (void)downloadNewsFeed {
    [GHNewsFeed newsFeedForUserNamed:self.username completionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
        }
    }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    
    [super dealloc];
}

@end
