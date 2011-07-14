//
//  GHRecentActivityViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRecentActivityViewController.h"
#import "GithubAPI.h"

@implementation GHRecentActivityViewController

@synthesize username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    [self pullToReleaseTableViewReloadData];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [self init])) {
        self.username = username;
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Recent activity", @"");
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    [super dealloc];
}

#pragma mark - instance methods

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [GHNewsFeed newsFeedForUserNamed:self.username completionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
        }
        [self pullToReleaseTableViewDidReloadData];
    }];
}

@end
