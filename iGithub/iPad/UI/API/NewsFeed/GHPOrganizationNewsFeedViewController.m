//
//  GHPOrganizationNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOrganizationNewsFeedViewController.h"



@implementation GHPOrganizationNewsFeedViewController

- (void)downloadNewsFeed {
    [GHAPIEventV3 eventsForOrganizationNamed:self.username
                                        page:1
                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                               self.isDownloadingEssentialData = NO;
                               
                               if (error) {
                                   [self handleError:error];
                               } else {
                                   self.events = array;
                               }
                           }];
}

@end
