//
//  GHNewOwnersNeedsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOwnersNeedsFeedViewController.h"



@implementation GHOwnersNeedsFeedViewController

#pragma mark - instance methods

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString
{
    _isDownloadingNewsFeedData = YES;
    
    [GHAPIEventV3 eventsForAuthenticatedUserSinceLastEventDateString:lastKnownEventDateString 
                                                   completionHandler:^(NSArray *events, NSError *error) {
                                                       if (error) {
                                                           [self handleError:error];
                                                       } else {
                                                           [self appendNewEvents:events];
                                                       }
                                                       
                                                       self.isDownloadingEssentialData = NO;
                                                       [self pullToReleaseTableViewDidReloadData];
                                                       
                                                       _isDownloadingNewsFeedData = NO;
                                                   }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedControl.selectedSegmentIndex = 0;
}

@end
