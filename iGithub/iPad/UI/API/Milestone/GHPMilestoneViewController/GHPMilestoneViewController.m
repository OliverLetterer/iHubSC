//
//  GHPMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMilestoneViewController.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPIssueViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewInfoSection                         0
#define kUITableViewControllerSectionInfoOpenIssues     1
#define kUITableViewControllerSectionInfoClosedIssues   2

#define kUITableViewControllerNumberOfSections          3



@implementation GHPMilestoneViewController

@synthesize milestone=_milestone, repository=_repository, milestoneNumber=_milestoneNumber;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.milestoneNumber = milestoneNumber;
        self.repository = repository;
        [self downloadMilestoneData];
    }
    return self;
}

- (void)downloadMilestoneData {
    [GHAPIMilestoneV3 milestoneOnRepository:self.repository number:self.milestoneNumber 
                          completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.milestone = milestone;
                                  self.title = self.milestone.title;
                                  if ([self isViewLoaded]) {
                                      [self.tableView reloadData];
                                  }
                              }
                          }];
}

#pragma mark - Notifications
#warning contains issue - create + update

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    // issue now has this milestone -> add based on state
    // issue changed state without milestone -> swap in arrays
    // issue was present but milestone changed -> remove
    
    if ([issue.milestone isEqualToMilestone:self.milestone]) {
        // issue belongs here
        if ([self.openIssues containsObject:issue] && [issue.state isEqualToString:kGHAPIIssueStateV3Closed]) {
            // state changed
            [self.openIssues removeObject:issue];
            [self.closedIssues insertObject:issue atIndex:0];
            changed = YES;
        } else if ([self.closedIssues containsObject:issue] && [issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
            // state changed
            [self.closedIssues removeObject:issue];
            [self.openIssues insertObject:issue atIndex:0];
            changed = YES;
        } else {
            if ([issue.state isEqualToString:kGHAPIIssueStateV3Closed]) {
                [self.closedIssues insertObject:issue atIndex:0];
                changed = YES;
            } else {
                [self.openIssues insertObject:issue atIndex:0];
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
        if ([issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
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
    
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
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
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    } else if (section == kUITableViewInfoSection) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
            
            GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
            
            GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewInfoSection) {
        if (indexPath.row == 0) {
            GHPInfoTableViewCell *cell = self.infoCell;   
            
            cell.textLabel.text = self.milestone.title;
            cell.detailTextLabel.text = self.milestone.milestoneDescription;
            
            return cell;
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == kUITableViewControllerSectionInfoClosedIssues || indexPath.section == kUITableViewControllerSectionInfoOpenIssues) && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewInfoSection) {
        return [GHPInfoTableViewCell heightWithContent:self.milestone.milestoneDescription];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIIssueV3 *issue = nil;
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        issue = [self.openIssues objectAtIndex:indexPath.row - 1];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
    }
    
    if (issue) {
        viewController = [[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:self.repository];
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    }
}

#pragma mark - caching

- (void)cacheHeightForOpenIssuesArray {
    [self.openIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title]] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewControllerSectionInfoOpenIssues]];
    }];
}

- (void)cacheHeightForClosedIssuesArray {
    [self.closedIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title]] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewControllerSectionInfoClosedIssues]];
    }];
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
        self.milestone = [decoder decodeObjectForKey:@"milestone"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _milestoneNumber = [decoder decodeObjectForKey:@"milestoneNumber"];
        _openIssues = [decoder decodeObjectForKey:@"openIssues"];
        _closedIssues = [decoder decodeObjectForKey:@"closedIssues"];
    }
    return self;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = nil;
    @try {
        title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    @catch (NSException *exception) {}
    
    if ([title isEqualToString:NSLocalizedString(@"Edit", @"")]) {
        // Create Issue
        GHUpdateMilestoneViewController *viewController = [[GHUpdateMilestoneViewController alloc] initWithMilestone:self.milestone repository:self.repository];
        viewController.delegate = self;
        
        [self presentViewControllerFromActionButton:viewController detatchNavigationController:YES animated:YES];
    } else if ([title isEqualToString:NSLocalizedString(@"Delete", @"")]) {
        [GHAPIMilestoneV3 deleteMilstoneOnRepository:self.repository withID:self.milestoneNumber completionHandler:^(NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Deleted Milestone", @"") message:self.milestone.title];
                [self.advancedNavigationController popViewController:self animated:YES];
            }
        }];
    }
}

#pragma mark - GHCreateMilestoneViewControllerDelegate

- (void)createMilestoneViewControllerDidCancel:(GHCreateMilestoneViewController *)createViewController {
    [_currentPopoverController dismissPopoverAnimated:YES];
}

- (void)createMilestoneViewController:(GHCreateMilestoneViewController *)createViewController didCreateMilestone:(GHAPIMilestoneV3 *)milestone {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Updated Milestone", @"") message:milestone.title];
    self.milestone = milestone;
    self.title = self.milestone.title;
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
    [_currentPopoverController dismissPopoverAnimated:YES];
}

@end
