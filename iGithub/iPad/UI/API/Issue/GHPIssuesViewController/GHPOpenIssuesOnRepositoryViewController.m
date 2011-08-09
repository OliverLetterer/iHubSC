//
//  GHPOpenIssuesOnRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOpenIssuesOnRepositoryViewController.h"


@implementation GHPOpenIssuesOnRepositoryViewController

#pragma mark - setters and getters

- (void)setRepository:(NSString *)repository {
    [super setRepository:repository];
    
    [GHAPIIssueV3 openedIssuesOnRepository:self.repository page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setDataArray:array nextPage:nextPage];
                             }
                         }];
}

#pragma mark - Notifications
#warning contains issue - update

- (void)issueCreationNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.repository isEqualToString:self.repository] && [issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
        [self.dataArray insertObject:issue atIndex:0];
        changed = YES;
    }
    
    if (changed) {
        [self cacheDataArrayHeights];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.repository isEqualToString:self.repository]) {
        NSUInteger index = [self.dataArray indexOfObject:issue];
        if (index != NSNotFound) {
            if ([issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
                [self.dataArray replaceObjectAtIndex:index withObject:issue];
            } else {
                [self.dataArray removeObjectAtIndex:index];
            }
            changed = YES;
        }
    }
    
    if (changed) {
        [self cacheDataArrayHeights];
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIIssueV3 openedIssuesOnRepository:self.repository page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self appendDataFromArray:array nextPage:nextPage];
                             }
                         }];
}

@end
