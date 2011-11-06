//
//  GHSingleRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRepositoryViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "NSString+Additions.h"
#import "GHWebViewViewController.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHIssueViewController.h"
#import "GHTableViewCell.h"
#import "GHUserViewController.h"
#import "GHCommitsViewController.h"
#import "GHViewRootDirectoryViewController.h"
#import "GHAPIMilestoneV3TableViewCell.h"
#import "GHMilestoneViewController.h"
#import "GHLabelTableViewCell.h"
#import "GHViewLabelViewController.h"
#import "ANNotificationQueue.h"
#import "GHColorAlertView.h"
#import "UIColor+GithubUI.h"

#define kUITableViewSectionUserData         0
#define kUITableViewSectionOwner            1
#define kUITableViewSectionLanguage         2
#define kUITableViewSectionCreatedAt        3
#define kUITableViewSectionSize             4
#define kUITableViewSectionHomepage         5
#define kUITableViewSectionWiki             6
#define kUITableViewSectionForkedFrom       7
#define kUITableViewSectionIssues           8
#define kUITableViewSectionMilestones       9
#define kUITableViewSectionLabels           10
#define kUITableViewSectionWatchingUsers    11
#define kUITableViewSectionPullRequests     12
#define kUITableViewSectionRecentCommits    13
#define kUITableViewSectionBrowseBranches   14
#define kUITableViewSectionCollaborators    15

#define kUITableViewNumberOfSections        16

#define kUIAlertViewAddCollaboratorTag      1337
#define kUIAlertViewLabelColorTag           1338
#define kUIAlertViewLabelNameTag            1339

#define kUIActionSheetSelectOrganizationTag 9865

@implementation GHRepositoryViewController

@synthesize repositoryString=_repositoryString, repository=_repository, issuesArray=_issuesArray, watchedUsersArray=_watchedUsersArray, deleteToken=_deleteToken, delegate=_delegate;
@synthesize pullRequests=_pullRequests, branches=_branches, milestones=_milestones, labels=_labels, organizations=_organizations, collaborators=_collaborators;

#pragma mark - setters and getters

- (void)setRepositoryString:(NSString *)repositoryString {
    _repositoryString = [repositoryString copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIRepositoryV3 repositoryNamed:self.repositoryString 
                 withCompletionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                     self.isDownloadingEssentialData = NO;
                     if (error) {
                         [self handleError:error];
                     } else {
                         self.repository = repository;
                         [self.tableView reloadData];
                     }
                     [self pullToReleaseTableViewDidReloadData];
                 }];
}

- (BOOL)canAdministrateRepository {
    return [self.repository.owner.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
}

- (BOOL)isFollowingRepository {
    return [self.watchedUsersArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login isEqualToString:obj]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] != NSNotFound;
}

#pragma mark - Notifications

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.repository isEqualToString:self.repositoryString]) {
        NSUInteger index = [self.issuesArray indexOfObject:issue];
        if (index != NSNotFound) {
            if (issue.isOpen) {
                [self.issuesArray replaceObjectAtIndex:index withObject:issue];
            } else {
                [self.issuesArray removeObjectAtIndex:index];
            }
            changed = YES;
        } else {
            if (issue.isOpen) {
                [self.issuesArray insertObject:issue atIndex:0];
                changed = YES;
            }
        }
    }
    
    if (changed) {
        [self cacheHeightForIssuesArray];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

- (void)issueCreationNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    
    if ([issue.repository isEqualToString:self.repositoryString] && issue.isOpen) {
        // issue belongs to us ;)
        [self.issuesArray insertObject:issue.repository atIndex:0];
        [self cacheHeightForIssuesArray];
        self.repository.openIssues = [NSNumber numberWithInt:[self.repository.openIssues intValue]+1 ];
        
        if (self.isViewLoaded) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionIssues] 
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepositoryString:(NSString *)repositoryString {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repositoryString = repositoryString;
        self.title = [[self.repositoryString componentsSeparatedByString:@"/"] lastObject];
    }
    return self;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section != kUITableViewSectionUserData && section != kUITableViewSectionOwner && section != kUITableViewSectionLanguage && section != kUITableViewSectionCreatedAt && section != kUITableViewSectionSize && section != kUITableViewSectionHomepage && section != kUITableViewSectionForkedFrom && section != kUITableViewSectionWiki;
}
- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionIssues) {
        return self.issuesArray == nil;
    } else if (section == kUITableViewSectionWatchingUsers) {
        return self.watchedUsersArray == nil;
    } else if (section == kUITableViewSectionPullRequests) {
        return self.pullRequests == nil;
    } else if (section == kUITableViewSectionRecentCommits) {
        return self.branches == nil;
    } else if (section == kUITableViewSectionBrowseBranches) {
        return self.branches == nil;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones == nil;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels == nil;
    } else if (section == kUITableViewSectionCollaborators) {
        return self.collaborators == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == kUITableViewSectionIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues (%@)", @""), self.repository.openIssues];
    } else if (section == kUITableViewSectionWatchingUsers) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Watching Users (%@)", @""), self.repository.watchers];
    } else if (section == kUITableViewSectionPullRequests) {
        cell.textLabel.text = NSLocalizedString(@"Pull Requests", @"");
    } else if (section == kUITableViewSectionRecentCommits) {
        cell.textLabel.text = NSLocalizedString(@"Recent Commits", @"");
    } else if (section == kUITableViewSectionBrowseBranches) {
        cell.textLabel.text = NSLocalizedString(@"Browse Content", @"");
    } else if (section == kUITableViewSectionMilestones) {
        cell.textLabel.text = NSLocalizedString(@"Milestones", @"");
    } else if (section == kUITableViewSectionLabels) {
        cell.textLabel.text = NSLocalizedString(@"Labels", @"");
    } else if (section == kUITableViewSectionCollaborators) {
        cell.textLabel.text = NSLocalizedString(@"Collaborators", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionIssues) {
        [GHAPIIssueV3 openedIssuesOnRepository:self.repositoryString page:1 
                             completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                     [tableView cancelDownloadInSection:section];
                                 } else {
                                     self.issuesArray = array;
                                     [self setNextPage:nextPage forSection:section];
                                     [self cacheHeightForIssuesArray];
                                     [tableView expandSection:section animated:YES];
                                 }
                             }];
    } else if (section == kUITableViewSectionWatchingUsers) {
        [GHAPIRepositoryV3 watchersOfRepository:self.repositoryString page:1 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [tableView cancelDownloadInSection:section];
                                      [self handleError:error];
                                  } else {
                                      self.watchedUsersArray = array;
                                      [self setNextPage:nextPage forSection:section];
                                      [tableView expandSection:section animated:YES];
                                  }
                              }];
    } else if (section == kUITableViewSectionPullRequests) {
        [GHAPIPullRequestV3 pullRequestsOnRepository:_repositoryString
                                                page:1
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [tableView cancelDownloadInSection:section];
                                           [self handleError:error];
                                       } else {
                                           self.pullRequests = array;
                                           [self setNextPage:nextPage forSection:section];
                                           
                                           [self cacheHeightForPullRequests];
                                           [self.tableView expandSection:section animated:YES];
                                           
                                           if ([self.pullRequests count] == 0) {
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                                               message:NSLocalizedString(@"This repository does not have any Pull Requests.", @"") 
                                                                                              delegate:nil 
                                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                     otherButtonTitles:nil];
                                               [alert show];
                                           }
                                       }
                                   }];
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseBranches) {
        [GHAPIRepositoryV3 branchesOnRepository:self.repositoryString page:1 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                      [tableView cancelDownloadInSection:section];
                                  } else {
                                      self.branches = array;
                                      [self setNextPage:nextPage forSection:section];
                                      [tableView expandSection:section animated:YES];
                                  }
                              }];
    } else if (section == kUITableViewSectionMilestones) {
        [GHAPIIssueV3 milestonesForIssueOnRepository:self.repositoryString withNumber:nil page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                           [tableView cancelDownloadInSection:section];
                                       } else {
                                           self.milestones = array;
                                           [self setNextPage:nextPage forSection:section];
                                           [tableView expandSection:section animated:YES];
                                       }
                                   }];
    } else if (section == kUITableViewSectionLabels) {
        [GHAPIRepositoryV3 labelsOnRepository:self.repositoryString 
                                         page:1 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [tableView cancelDownloadInSection:section];
                                    [self handleError:error];
                                } else {
                                    self.labels = array;
                                    [self setNextPage:nextPage forSection:section];
                                    [tableView expandSection:section animated:YES];
                                }
                            }];
    } else if (section == kUITableViewSectionCollaborators) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repositoryString page:1 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [tableView cancelDownloadInSection:section];
                                            [self handleError:error];
                                        } else {
                                            self.collaborators = array;
                                            [self setNextPage:nextPage forSection:section];
                                            [tableView expandSection:section animated:YES];
                                        }
                                    }];
    }
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionLabels) {
        [GHAPIRepositoryV3 labelsOnRepository:self.repositoryString 
                                         page:page 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [self setNextPage:nextPage forSection:section];
                                    [self.labels addObjectsFromArray:array];
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                            }];
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseBranches) {
        [GHAPIRepositoryV3 branchesOnRepository:self.repositoryString page:page 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      [self.branches addObjectsFromArray:array];
                                      [self setNextPage:nextPage forSection:section];
                                      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                                                    withRowAnimation:UITableViewRowAnimationAutomatic];
                                  }
                              }];
    } else if (section == kUITableViewSectionIssues) {
        [GHAPIIssueV3 openedIssuesOnRepository:self.repositoryString page:page 
                             completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     [self.issuesArray addObjectsFromArray:array];
                                     [self setNextPage:nextPage forSection:section];
                                     [self cacheHeightForIssuesArray];
                                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                   withRowAnimation:UITableViewRowAnimationAutomatic];
                                 }
                             }];
    } else if (section == kUITableViewSectionMilestones) {
        [GHAPIIssueV3 milestonesForIssueOnRepository:self.repositoryString withNumber:nil page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           [self.milestones addObjectsFromArray:array];
                                           [self setNextPage:nextPage forSection:section];
                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                   }];
    } else if (section == kUITableViewSectionCollaborators) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repositoryString page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            [self.collaborators addObjectsFromArray:array];
                                            [self setNextPage:nextPage forSection:section];
                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
                                    }];
    } else if (section == kUITableViewSectionPullRequests) {
        [GHAPIPullRequestV3 pullRequestsOnRepository:_repositoryString
                                                page:page
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           [self.pullRequests addObjectsFromArray:array];
                                           [self setNextPage:nextPage forSection:section];
                                           
                                           [self cacheHeightForPullRequests];
                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                   }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!self.repository) {
        return 0;
    }
    
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionUserData) {
        // title + description
        return 1;
    } else if (section == kUITableViewSectionIssues) {
        // issues
        // title, issues, create new issue
        if ([self.repository.openIssues unsignedIntValue] == 0) {
            return 0;
        }
        return [self.issuesArray count] + 1;
    } else if (section == kUITableViewSectionWatchingUsers) {
        if ([self.repository.watchers intValue] == 0) {
            return 0;
        }
        return [self.watchedUsersArray count] + 1;
    } else if (section == kUITableViewSectionPullRequests) {
        return [self.pullRequests count] + 1;
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseBranches) {
        return [self.branches count] + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels.count + 1;
    } else if (section == kUITableViewSectionOwner) {
        return 1;
    } else if (section == kUITableViewSectionLanguage) {
        if (self.repository.hasLanguage) {
            return 1;
        }
    } else if (section == kUITableViewSectionCreatedAt) {
        return 1;
    } else if (section == kUITableViewSectionSize) {
        return 1;
    } else if (section == kUITableViewSectionHomepage) {
        if (self.repository.hasHomepage) {
            return 1;
        }
    } else if (section == kUITableViewSectionForkedFrom) {
        if (self.repository.isForked) {
            return 1;
        }
    } else if (section == kUITableViewSectionCollaborators) {
        if (!self.canAdministrateRepository) {
            return 0;
        }
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionWiki) {
        if ([self.repository.hasWiki boolValue]) {
            return 1;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 0) {
            // title + description
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if (self.repository.isForked) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", self.repository.owner.login, self.repository.name];
                cell.descriptionLabel.text = self.repository.description;
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"forked from %@", @""), [NSString stringWithFormat:@"%@/%@", self.repository.parent.owner.login, self.repository.parent.name]];
            } else {
                cell.textLabel.text = self.repository.name;
                cell.descriptionLabel.text = self.repository.description;
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created by %@", @""), self.repository.owner.login];
            }
            
            if ([self.repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsOwnerTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Owner", @"");
            cell.detailTextLabel.text = self.repository.owner.login;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionLanguage) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Language", @"");
            cell.detailTextLabel.text = self.repository.language;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionCreatedAt) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Created", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), self.repository.createdAt.prettyTimeIntervalSinceNow];
            
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionSize) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Size", @"");
            cell.detailTextLabel.text = [NSString stringFormFileSize:[self.repository.size longLongValue] ];
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionHomepage) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsHomePageTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Homepage", @"");
            cell.detailTextLabel.text = self.repository.homepage;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionWiki) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsHomePageTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Wiki", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Available", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionForkedFrom) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsHomePageTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Forked from", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", self.repository.parent.owner.login, self.repository.parent.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionIssues) {
        // issues
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIIssueV3 *issue = [self.issuesArray objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
        ;
        
        cell.descriptionLabel.text = issue.title;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionCollaborators) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundViewCollaborator";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row - 1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionWatchingUsers) {
        // watching users
        if (indexPath.row > 0 && indexPath.row <= [self.watchedUsersArray count]) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIUserV3 *user = [self.watchedUsersArray objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
            cell.textLabel.text = user.login;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPullRequests) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        GHAPIPullRequestV3 *pullRequest = [self.pullRequests objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = pullRequest.user.login;
        cell.descriptionLabel.text = pullRequest.title;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), pullRequest.createdAt.prettyTimeIntervalSinceNow];
        
        [self updateImageView:cell.imageView
                  atIndexPath:indexPath
          withAvatarURLString:pullRequest.user.avatarURL];
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionRecentCommits || indexPath.section == kUITableViewSectionBrowseBranches) {
        if (indexPath.row > 0) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = branch.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        NSString *CellIdentifier = @"MilestoneCell";
        
        GHAPIMilestoneV3TableViewCell *cell = (GHAPIMilestoneV3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHAPIMilestoneV3TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = milestone.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%d%% completed)", @""), milestone.dueFormattedString, (int)(milestone.progress*100)];
        
        cell.progressView.progress = milestone.progress;
        if (milestone.dueInTime) {
            [cell.progressView setTintColor:[UIColor greenColor] ];
        } else {
            [cell.progressView setTintColor:[UIColor redColor] ];
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionLabels) {
        if (indexPath.row > 0) {
            NSString *CellIdentifier = @"GHLabelTableViewCell";
            
            GHLabelTableViewCell *cell = (GHLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = label.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
            
            return cell;
        }
    }
    
    return self.dummyCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section == kUITableViewSectionCollaborators && indexPath.row > 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row-1];
        
        [GHAPIRepositoryV3 deleteCollaboratorNamed:user.login onRepository:self.repositoryString 
                                 completionHandler:^(NSError *error) {
                                     if (error) {
                                         [self handleError:error];
                                     } else {
                                         [self.collaborators removeObjectAtIndex:indexPath.row-1];
                                         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                     }
                                 }];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionUserData && indexPath.row == 0) {
        // title + description
        if (![self isHeightCachedForRowAtIndexPath:indexPath]) {
            [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:self.repository.description] 
            forRowAtIndexPath:indexPath];
        }
        
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionIssues && indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionPullRequests && indexPath.row > 0 && indexPath.row <= [self.pullRequests count]) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionMilestones && indexPath.row > 0) {
        return kGHAPIMilestoneV3TableViewCellHeight;
    }
    
    return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionForkedFrom && indexPath.row == 0) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", self.repository.parent.owner.login, self.repository.parent.name] ];
        repoViewController.delegate = self;
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionOwner && indexPath.row == 0) {
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:self.repository.owner.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionHomepage && indexPath.row == 0) {
        NSURL *URL = [NSURL URLWithString:self.repository.homepage];
        
        GHWebViewViewController *webViewController = [[GHWebViewViewController alloc] initWithURL:URL];
        [self.navigationController pushViewController:webViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionIssues) {
        GHAPIIssueV3 *issue = [self.issuesArray objectAtIndex:indexPath.row-1];
        GHIssueViewController *issueViewController = [[GHIssueViewController alloc] 
                                                      initWithRepository:self.repositoryString 
                                                      issueNumber:issue.number];
        [self.navigationController pushViewController:issueViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionWatchingUsers) {
        // watched user
        GHAPIUserV3 *user = [self.watchedUsersArray objectAtIndex:indexPath.row-1];
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionPullRequests) {
        GHAPIPullRequestV3 *pullRequest = [self.pullRequests objectAtIndex:indexPath.row-1];
        
        GHIssueViewController *viewIssueViewController = [[GHIssueViewController alloc] initWithRepository:_repositoryString
                                                                                               issueNumber:pullRequest.ID];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionRecentCommits) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        GHCommitsViewController *recentViewController = [[GHCommitsViewController alloc] initWithRepository:self.repositoryString 
                                                                                                                  branchName:branch.name branchHash:branch.ID];
        [self.navigationController pushViewController:recentViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionBrowseBranches) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        GHViewRootDirectoryViewController *rootViewController = [[GHViewRootDirectoryViewController alloc] initWithRepository:self.repositoryString
                                                                                                                        branch:branch.name
                                                                                                                          hash:branch.ID];
        [self.navigationController pushViewController:rootViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionMilestones && indexPath.row > 0) {
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row - 1];
        
        GHMilestoneViewController *milestoneViewController = [[GHMilestoneViewController alloc] initWithRepository:self.repositoryString
                                                                                                            milestoneNumber:milestone.number];
        [self.navigationController pushViewController:milestoneViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionLabels && indexPath.row > 0) {
        GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row - 1];
        
        GHViewLabelViewController *labelViewController = [[GHViewLabelViewController alloc] initWithRepository:self.repositoryString  
                                                                                                          label:label];
        [self.navigationController pushViewController:labelViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionCollaborators) {
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionWiki) {
        if (indexPath.row == 0) {
            NSURL *repoURL = [NSURL URLWithString:self.repository.HTMLURL];
            NSURL *wikiURL = [repoURL URLByAppendingPathComponent:@"wiki"];
            GHWebViewViewController *viewController = [[GHWebViewViewController alloc] initWithURL:wikiURL];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionUserData) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@", [self.repositoryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
        webViewController.webDelegate = self;
        webViewController.navigationBar.tintColor = [UIColor defaultNavigationBarTintColor];
        webViewController.toolbar.tintColor = [UIColor defaultNavigationBarTintColor];
        [self presentViewController:webViewController animated:YES completion:nil];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - SVModalWebViewControllerDelegate

- (void)modalWebViewControllerIsDone:(SVModalWebViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewAddCollaboratorTag) {
        // new collaborator
        if (buttonIndex == 1) {
            // OK clicked
            NSString *username = [alertView textFieldAtIndex:0].text;
            [GHAPIRepositoryV3 addCollaboratorNamed:username onRepository:self.repositoryString 
                                  completionHandler:^(NSError *error) {
                                      if (error) {
                                          [self handleError:error];
                                      } else {
                                          [self.tableView collapseSection:kUITableViewSectionCollaborators animated:NO];
                                          self.collaborators = nil;
                                          [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Added Collaborator", @"") message:username];
                                          [self.tableView expandSection:kUITableViewSectionCollaborators animated:NO];
                                      }
                                  }];
        }
    } else if (alertView.tag == kUIAlertViewLabelColorTag) {
        if (buttonIndex == 1) {
            GHColorAlertView *alert = (GHColorAlertView *)alertView;
            _labelColor = alert.selectedColor;
            
            UIAlertView *secondAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Name", @"") 
                                                             message:nil 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            secondAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            secondAlert.tag = kUIAlertViewLabelNameTag;
            [secondAlert show];
        }
    } else if (alertView.tag == kUIAlertViewLabelNameTag) {
        if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
            
            [GHAPIRepositoryV3 createLabelOnRepository:self.repositoryString name:name color:_labelColor 
                                     completionHandler:^(GHAPILabelV3 *label, NSError *error) {
                                         if (error) {
                                             [self handleError:error];
                                         } else {
                                             [self.labels insertObject:label atIndex:0];
                                             if (self.isViewLoaded) {
                                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionLabels] withRowAnimation:UITableViewRowAnimationAutomatic];
                                             }
                                         }
                                     }];
        }
    } else {
        if (buttonIndex == 1) {
            self.view.userInteractionEnabled = NO;
            [GHRepository deleteRepository:self.repositoryString 
                                 withToken:self.deleteToken 
                         completionHandler:^(NSError *error) {
                             self.actionButtonActive = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self.delegate singleRepositoryViewControllerDidDeleteRepository:self];
                             }
                         }];
        }
    }
}

#pragma mark - height caching

- (void)cacheHeightForIssuesArray {
    [self.issuesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionIssues];
        CGFloat height = [GHDescriptionTableViewCell heightWithContent:issue.title];
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
}

- (void)cacheHeightForPullRequests {
    NSInteger i = 1;
    for (GHAPIPullRequestV3 *pullRequest in self.pullRequests) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:pullRequest.title] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewSectionPullRequests] ];
        i++;
    }
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHRepositoryViewController *)singleRepositoryViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GHCreateIssueTableViewControllerDelegate

- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHAPIIssueV3 *)issue {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Issue", @"") message:issue.title];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GHCreateMilestoneViewControllerDelegate

- (void)createMilestoneViewController:(GHCreateMilestoneViewController *)createViewController didCreateMilestone:(GHAPIMilestoneV3 *)milestone {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Milestone", @"") message:milestone.title];
    [self.milestones insertObject:milestone atIndex:0];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionMilestones] 
                  withRowAnimation:UITableViewRowAnimationNone];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)createMilestoneViewControllerDidCancel:(GHCreateMilestoneViewController *)createViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetSelectOrganizationTag) {
        if (buttonIndex < actionSheet.numberOfButtons - 1) {
            [self organizationsActionSheetDidSelectOrganizationAtIndex:buttonIndex];
        }
    } else if (actionSheet.tag == kUIActionButtonActionSheetTag) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Create Issue", @"")]) {
            // Create Issue
            GHCreateIssueTableViewController *viewController = [[GHCreateIssueTableViewController alloc] initWithRepository:self.repositoryString];
            viewController.delegate = self;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentModalViewController:navController animated:YES];
        } else if ([title isEqualToString:NSLocalizedString(@"Delete", @"")]) {
            self.actionButtonActive = YES;
            [GHRepository deleteTokenForRepository:self.repositoryString 
                             withCompletionHandler:^(NSString *deleteToken, NSError *error) {
                                 if (error) {
                                     self.actionButtonActive = NO;
                                     [self handleError:error];
                                 } else {
                                     self.deleteToken = deleteToken;
                                     
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete %@", @""), self.repositoryString] 
                                                                                     message:[NSString stringWithFormat:NSLocalizedString(@"Are you absolutely sure that you want to delete %@? This action can't be undone!", @""), self.repositoryString] 
                                                                                    delegate:self 
                                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                                           otherButtonTitles:NSLocalizedString(@"Delete", @""), nil];
                                     [alert show];
                                 }
                             }];
        } else if ([title isEqualToString:NSLocalizedString(@"Unwatch", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIRepositoryV3 unwatchRepository:self.repositoryString 
                               completionHandler:^(NSError *error) {
                                   self.actionButtonActive = NO;
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       _isWatchingRepository = NO;
                                       [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Stopped watching", @"") message:self.repositoryString];
                                   }
                               }];
        } else if ([title isEqualToString:NSLocalizedString(@"Watch", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIRepositoryV3 watchRepository:self.repositoryString 
                             completionHandler:^(NSError *error) {
                                 self.actionButtonActive = NO;
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     _isWatchingRepository = YES;
                                     [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Now watching", @"") message:self.repositoryString];
                                 }
                             }];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork to my Account", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIRepositoryV3 forkRepository:self.repositoryString 
                               toOrganization:nil 
                            completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                                self.actionButtonActive = NO;
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully forked", @"") message:self.repositoryString];
                                }
                            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork to an Organization", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIOrganizationV3 organizationsOfUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       
                                       if (error) {
                                           [self handleError:error];
                                           self.actionButtonActive = NO;
                                       } else {
                                           self.organizations = array;
                                           
                                           if (self.organizations.count > 0) {
                                               if (self.organizations.count == 1) {
                                                   // we only have one organization, act as if user select this only organization
                                                   [self organizationsActionSheetDidSelectOrganizationAtIndex:0];
                                               } else {
                                                   UIActionSheet *sheet = [[UIActionSheet alloc] init];
                                                   
                                                   [sheet setTitle:NSLocalizedString(@"Select an Organization", @"")];
                                                   
                                                   for (GHAPIOrganizationV3 *organization in self.organizations) {
                                                       [sheet addButtonWithTitle:organization.login];
                                                   }
                                                   
                                                   [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
                                                   sheet.cancelButtonIndex = sheet.numberOfButtons-1;
                                                   
                                                   sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                                                   sheet.tag = kUIActionSheetSelectOrganizationTag;
                                                   sheet.delegate = self;
                                                   
                                                   [sheet showInView:self.tabBarController.view];
                                               }
                                           } else {
                                               self.actionButtonActive = NO;
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                               message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                              delegate:nil 
                                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                     otherButtonTitles:nil];
                                               [alert show];
                                           }
                                       }
                                       
                                   }];
        } else if ([title isEqualToString:NSLocalizedString(@"Create Milestone", @"")]) {
            GHCreateMilestoneViewController *viewController = [[GHCreateMilestoneViewController alloc] initWithRepository:self.repositoryString];
            viewController.delegate = self;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            
            [self presentModalViewController:navController animated:YES];
        } else if ([title isEqualToString:NSLocalizedString(@"Create Label", @"")]) {
            GHColorAlertView *alert = [[GHColorAlertView alloc] initWithTitle:NSLocalizedString(@"Select Color", @"") 
                                                                      message:nil 
                                                                     delegate:self 
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                            otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            alert.tag = kUIAlertViewLabelColorTag;
            [alert show];
            
        } else if ([title isEqualToString:NSLocalizedString(@"Add Collaborator", @"")]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Username", @"") 
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                  otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewAddCollaboratorTag;
            [alert show];
        }
    }
}

- (void)organizationsActionSheetDidSelectOrganizationAtIndex:(NSUInteger)index {
    GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:index];
    
    [GHAPIRepositoryV3 forkRepository:self.repositoryString 
                       toOrganization:organization.login 
                    completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                        self.actionButtonActive = NO;
                        if (error) {
                            [self handleError:error];
                        } else {
                            [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Forked Repository to", @"") message:organization.login];
                        }
                    }];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repositoryString forKey:@"repositoryString"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeBool:_hasWatchingData forKey:@"hasWatchingData"];
    [encoder encodeBool:_isWatchingRepository forKey:@"isWatchingRepository"];
    [encoder encodeObject:_deleteToken forKey:@"deleteToken"];
    [encoder encodeObject:_pullRequests forKey:@"pullRequests"];
    [encoder encodeObject:_branches forKey:@"branches"];
    [encoder encodeObject:_labels forKey:@"labels"];
    [encoder encodeObject:_milestones forKey:@"milestones"];
    [encoder encodeObject:_organizations forKey:@"organizations"];
    [encoder encodeObject:_issuesArray forKey:@"issuesArray"];
    [encoder encodeObject:_watchedUsersArray forKey:@"watchedUsersArray"];
    [encoder encodeObject:_collaborators forKey:@"collaborators"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repositoryString = [decoder decodeObjectForKey:@"repositoryString"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _hasWatchingData = [decoder decodeBoolForKey:@"hasWatchingData"];
        _isWatchingRepository = [decoder decodeBoolForKey:@"isWatchingRepository"];
        _deleteToken = [decoder decodeObjectForKey:@"deleteToken"];
        _pullRequests = [decoder decodeObjectForKey:@"pullRequests"];
        _branches = [decoder decodeObjectForKey:@"branches"];
        _labels = [decoder decodeObjectForKey:@"labels"];
        _milestones = [decoder decodeObjectForKey:@"milestones"];
        _organizations = [decoder decodeObjectForKey:@"organizations"];
        _issuesArray = [decoder decodeObjectForKey:@"issuesArray"];
        _watchedUsersArray = [decoder decodeObjectForKey:@"watchedUsersArray"];
        _collaborators = [decoder decodeObjectForKey:@"collaborators"];
    }
    return self;
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    [GHAPIRepositoryV3 isWatchingRepository:self.repositoryString 
                          completionHandler:^(BOOL watching, NSError *error) {
                              if (error) {
                                  [self failedToDownloadDataToDisplayActionButtonWithError:error];
                              } else {
                                  _hasWatchingData = YES;
                                  _isWatchingRepository = watching;
                                  [self didDownloadDataToDisplayActionButton];
                              }
                          }];
}

- (UIActionSheet *)actionButtonActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.repository.fullRepositoryName;
    NSUInteger currentButtonIndex = 0;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Create Issue", @"")];
    currentButtonIndex++;
    
    if (!self.canAdministrateRepository) {
        if (_isWatchingRepository) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Unwatch", @"")];
            currentButtonIndex++;
        } else {
            [sheet addButtonWithTitle:NSLocalizedString(@"Watch", @"")];
            currentButtonIndex++;
        }
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Fork to my Account", @"")];
        currentButtonIndex++;
    }
    
    if (self.canAdministrateRepository) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Create Milestone", @"")];
        currentButtonIndex++;
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Create Label", @"")];
        currentButtonIndex++;
    }
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Fork to an Organization", @"")];
    currentButtonIndex++;
    
    if (self.canAdministrateRepository) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Add Collaborator", @"")];
        currentButtonIndex++;
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
        sheet.destructiveButtonIndex = currentButtonIndex;
        currentButtonIndex++;
    }
    
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
    if (self.canAdministrateRepository) {
        return NO;
    }
    return !_hasWatchingData;
}

@end
