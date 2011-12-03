//
//  GHViewMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHMilestoneViewController.h"
#import "GHAPIMilestoneV3TableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHIssueViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewControllerSectionInfo               0
#define kUITableViewControllerSectionInfoOpenIssues     1
#define kUITableViewControllerSectionInfoClosedIssues   2

#define kUITableViewControllerNumberOfSections          3

@implementation GHMilestoneViewController

@synthesize milestone=_milestone, repository=_repository, milestoneNumber=_milestoneNumber;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - setters and getters

- (void)setMilestone:(GHAPIMilestoneV3 *)milestone {
    if (milestone != _milestone) {
        _milestone = milestone;
        
        self.title = _milestone.title;
        if ([self isViewLoaded]) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.milestoneNumber = milestoneNumber;
        self.repository = repository;
        [self downloadMilestoneData];
    }
    return self;
}

- (void)downloadMilestoneData {
    self.isDownloadingEssentialData = YES;
    [GHAPIMilestoneV3 milestoneOnRepository:self.repository number:self.milestoneNumber 
                          completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                              self.isDownloadingEssentialData = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.milestone = milestone;
                              }
                          }];
}

#pragma mark - Notifications

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;

    if ([self.milestone isEqualToMilestone:issue.milestone]) {
        // issue belongs here
        NSUInteger openIndex = [self.openIssues indexOfObject:issue];
        if (openIndex != NSNotFound) {
            if (issue.isOpen) {
                [self.openIssues replaceObjectAtIndex:openIndex withObject:issue];
            } else {
                [self.openIssues removeObjectAtIndex:openIndex];
                [self.closedIssues insertObject:issue atIndex:0];
            }
            changed = YES;
        } else {
            if (issue.isOpen) {
                [self.openIssues insertObject:issue atIndex:0];
                changed = YES;
            }
        }
        
        NSUInteger closedIndex = [self.closedIssues indexOfObject:issue];
        if (closedIndex != NSNotFound) {
            if (!issue.isOpen) {
                [self.closedIssues replaceObjectAtIndex:closedIndex withObject:issue];
            } else {
                [self.closedIssues removeObjectAtIndex:closedIndex];
                [self.openIssues insertObject:issue atIndex:0];
            }
            changed = YES;
        } else {
            if (!issue.isOpen) {
                [self.closedIssues insertObject:issue atIndex:0];
                changed = YES;
            }
        }
    } else {
        // issue doesnt belong here
        if ([self.openIssues containsObject:issue]) {
            [self.openIssues removeObject:issue];
            changed = YES;
        }
        if ([self.closedIssues containsObject:issue]) {
            [self.closedIssues removeObject:issue];
            changed = YES;
        }
    }
    
    if (changed) {
        [self cacheHeightForOpenIssuesArray];
        [self cacheHeightForClosedIssuesArray];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

- (void)issueCreationNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.milestone isEqualToMilestone:self.milestone]) {
        if (issue.isOpen) {
            [self.openIssues insertObject:issue atIndex:0];
        } else {
            [self.closedIssues insertObject:issue atIndex:0];
        }
        changed = YES;
    }
    
    if (changed) {
        [self cacheHeightForOpenIssuesArray];
        [self cacheHeightForClosedIssuesArray];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewControllerSectionInfoOpenIssues || section == kUITableViewControllerSectionInfoClosedIssues;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues == nil;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        cell.textLabel.text = NSLocalizedString(@"Open Issues", @"");
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        cell.textLabel.text = NSLocalizedString(@"Closed Issues", @"");
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil 
                                   state:kGHAPIIssueStateV3Open page:page 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.openIssues addObjectsFromArray:array];
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil
                                   state:kGHAPIIssueStateV3Closed page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.closedIssues addObjectsFromArray:array];
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Open page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.openIssues = array;
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Closed page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.closedIssues = array;
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!self.milestone) {
        return 0;
    }
    return kUITableViewControllerNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewControllerSectionInfo) {
        return 1;
    } else if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"MilestoneCell";
            
            GHAPIMilestoneV3TableViewCell *cell = (GHAPIMilestoneV3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHAPIMilestoneV3TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            GHAPIMilestoneV3 *milestone = self.milestone;
            
            cell.textLabel.text = milestone.title;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%d%% completed)", @""), milestone.dueFormattedString, (int)(milestone.progress*100)];
            
            cell.progressView.progress = milestone.progress;
            
            if (milestone.dueInTime) {
                [cell.progressView setTintColor:[UIColor greenColor] ];
            } else {
                [cell.progressView setTintColor:[UIColor redColor] ];
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
            return cell;
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewControllerSectionInfo) {
        return kGHAPIMilestoneV3TableViewCellHeight;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
        
        GHIssueViewController *issueViewController = [[GHIssueViewController alloc] initWithRepository:self.repository 
                                                                                                              issueNumber:issue.number];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
        
        GHIssueViewController *issueViewController = [[GHIssueViewController alloc] initWithRepository:self.repository 
                                                                                                              issueNumber:issue.number];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - caching

- (void)cacheHeightForOpenIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.openIssues) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:issue.title] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoOpenIssues] ];
        i++;
    }
}

- (void)cacheHeightForClosedIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.closedIssues) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:issue.title] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoClosedIssues] ];
        i++;
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_milestone forKey:@"milestone"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_milestoneNumber forKey:@"milestoneNumber"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_closedIssues forKey:@"closedIssues"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _milestone = [decoder decodeObjectForKey:@"milestone"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _milestoneNumber = [decoder decodeObjectForKey:@"milestoneNumber"];
        _openIssues = [decoder decodeObjectForKey:@"openIssues"];
        _closedIssues = [decoder decodeObjectForKey:@"closedIssues"];
    }
    return self;
}

#pragma mark - GHCreateMilestoneViewControllerDelegate

- (void)createMilestoneViewControllerDidCancel:(GHCreateMilestoneViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createMilestoneViewController:(GHCreateMilestoneViewController *)createViewController didCreateMilestone:(GHAPIMilestoneV3 *)milestone {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Updated Milestone", @"") message:milestone.title];
    self.milestone = milestone;
    self.title = self.milestone.title;
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionButtonActionSheetTag) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Edit", @"")]) {
            // Create Issue
            GHUpdateMilestoneViewController *viewController = [[GHUpdateMilestoneViewController alloc] initWithMilestone:self.milestone repository:self.repository];
            viewController.delegate = self;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:navController animated:YES completion:nil];
        } else if ([title isEqualToString:NSLocalizedString(@"Delete", @"")]) {
            [GHAPIMilestoneV3 deleteMilstoneOnRepository:self.repository withID:self.milestoneNumber completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Deleted Milestone", @"") message:self.milestone.title];
                    if (self.navigationController.topViewController == self) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }];
        }
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    [GHAPIRepositoryV3 isUser:username 
     collaboratorOnRepository:self.repository 
            completionHandler:^(BOOL state, NSError *error) {
                if (error) {
                    [self failedToDownloadDataToDisplayActionButtonWithError:error];
                } else {
                    _hasCollaboratorData = YES;
                    _isCollaborator = state || [self.repository hasPrefix:username];
                    [self didDownloadDataToDisplayActionButton];
                }
            }];
}

- (UIActionSheet *)actionButtonActionSheet {
    if (!_isCollaborator) {
        return nil;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.milestone.title;
    NSUInteger currentButtonIndex = 0;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Edit", @"")];
    currentButtonIndex++;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
    sheet.destructiveButtonIndex = currentButtonIndex;
    currentButtonIndex++;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = currentButtonIndex;
    currentButtonIndex++;
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.delegate = self;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    return !_hasCollaboratorData;
}

@end
