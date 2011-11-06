//
//  GHNewOwnersNeedsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewOwnersNeedsFeedViewController.h"



@implementation GHNewOwnersNeedsFeedViewController

#pragma mark - instance methods

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString
{
    [GHAPIEventV3 eventsForAuthenticatedUserSinceLastEventDateString:lastKnownEventDateString 
                                                   completionHandler:^(NSArray *events, NSError *error) {
                                                       if (error) {
                                                           [self handleError:error];
                                                       } else {
                                                           [self appendNewEvents:events];
                                                       }
                                                       
                                                       self.isDownloadingEssentialData = NO;
                                                       [self pullToReleaseTableViewDidReloadData];
                                                   }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedControl.selectedSegmentIndex = 0;
}

@end
