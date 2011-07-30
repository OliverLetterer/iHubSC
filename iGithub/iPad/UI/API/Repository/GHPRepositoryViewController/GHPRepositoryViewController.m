//
//  GHPRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPRepositoryViewController.h"
#import "NSString+Additions.h"
#import "GHPUserTableViewCell.h"
#import "GHPUserViewController.h"
#import "GHPLabelTableViewCell.h"
#import "GHPWatchingRepositoryUsersViewController.h"
#import "GHPCollaboratorsViewController.h"
#import "GHPCommitsViewController.h"
#import "GHPOpenIssuesOnRepositoryViewController.h"
#import "GHPMileStonesOnRepositoryViewController.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPPullRequestsOnRepositoryViewController.h"
#import "GHPRootDirectoryViewController.h"
#import "GHPLabelViewController.h"
#import "ANNotificationQueue.h"
#import "GHWebViewViewController.h"
#import "GHViewREADMEViewController.h"

#define kUIAlertViewTagDeleteRepository     1337
#define kUIAlertViewTagAddCollaborator      1338

#define kUIActionSheetTagAction             1339
#define kUIActionSheetTagSelectOrganization 1340

#define kUITableViewSectionInfo             0
#define kUITableViewSectionOwner            1
#define KUITableViewSectionREADME           2
#define kUITableViewSectionFurtherContent   3
#define kUITableViewSectionRecentCommits    4
#define kUITableViewSectionBrowseContent    5
#define kUITableViewSectionLabels           6

#define kUITableViewNumberOfSections        7

@implementation GHPRepositoryViewController

@synthesize repositoryString=_repositoryString, repository=_repository, deleteToken=_deleteToken, organizations=_organizations;
@synthesize labels=_labels, branches=_branches;

#pragma mark - setters and getters

- (void)setRepositoryString:(NSString *)repositoryString {
    _repositoryString = [repositoryString copy];
    self.isDownloadingEssentialData = YES;
    [GHAPIRepositoryV3 repositoryNamed:_repositoryString 
                 withCompletionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                     self.isDownloadingEssentialData = NO;
                     if (error) {
                         [self handleError:error];
                     } else {
                         self.repository = repository;
                         if (self.isViewLoaded) {
                             [self.tableView reloadData];
                         }
                     }
                 }];
}

- (NSString *)metaInformationString {
    NSMutableString *string = [NSMutableString stringWithCapacity:500];
    
    [string appendFormat:NSLocalizedString(@"Size: %@\n", @""), [NSString stringFormFileSize:[self.repository.size longLongValue]] ];
    [string appendFormat:NSLocalizedString(@"Created: %@\n", @""), [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), self.repository.createdAt.prettyTimeIntervalSinceNow] ];
    if (self.repository.hasLanguage) {
        [string appendFormat:NSLocalizedString(@"Language: %@\n", @""), self.repository.language];
    }
    
    return string;
}

- (BOOL)canAdministrateRepository {
    return [self.repository.owner.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
}

#pragma mark - Initialization

- (id)initWithRepositoryString:(NSString *)repositoryString {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repositoryString = repositoryString;
    }
    return self;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionLabels || section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionLabels) {
        return self.labels == nil;
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent) {
        return self.branches == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionLabels) {
        cell.textLabel.text = NSLocalizedString(@"Labels", @"");
    } else if (section == kUITableViewSectionRecentCommits) {
        cell.textLabel.text = NSLocalizedString(@"Recent Commits", @"");
    } else if (section == kUITableViewSectionBrowseContent) {
        cell.textLabel.text = NSLocalizedString(@"Browse Content", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionLabels) {
        [GHAPIRepositoryV3 labelsOnRepository:self.repositoryString page:1 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [self handleError:error];
                                    [tableView cancelDownloadInSection:section];
                                } else {
                                    self.labels = array;
                                    [self setNextPage:nextPage forSection:section];
                                    [tableView expandSection:section animated:YES];
                                }
                            }];
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent) {
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
    }
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionLabels) {
        [GHAPIRepositoryV3 labelsOnRepository:self.repositoryString page:page 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [self.labels addObjectsFromArray:array];
                                    [self setNextPage:nextPage forSection:section];
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                            }];
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent) {
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
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.repository) {
        return 0;
    }
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionInfo) {
        return 2;
    } else if (section == kUITableViewSectionFurtherContent) {
        NSInteger result = 5;
        if (self.repository.hasWiki) {
            result++;
        }
        return result;
    } else if (section == kUITableViewSectionOwner) {
        if (self.repository.isForked) {
            return 2;
        }
        return 1;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels.count + 1;
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent) {
        return self.branches.count + 1;
    } else if (section == KUITableViewSectionREADME) {
        return 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            GHPInfoTableViewCell *cell = self.infoCell;   
            
            cell.textLabel.text = self.repository.fullRepositoryName;
            cell.detailTextLabel.text = self.repository.description;
            
            if ([self.repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"GHPInfoTableViewCellDelegate";
            GHPInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                              reuseIdentifier:CellIdentifier];
            }
            
            [cell.actionButton removeFromSuperview];
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = self.metaInformationString;
            cell.imageView.image = nil;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionFurtherContent) {
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Open Issues", @"");
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Milestones", @"");
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Collaborators", @"");
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Watching Users", @"");
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Pull Requests", @"");
        } else if (indexPath.row == 5) {
            if (self.repository.hasWiki) {
                cell.textLabel.text = NSLocalizedString(@"Wiki", @"");
            }
        } else {
            cell.textLabel.text = nil;
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHPUserTableViewCell";
            GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                    reuseIdentifier:CellIdentifier];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.repository.owner.avatarURL];
            cell.textLabel.text = self.repository.owner.login;
            
            return cell;
        } else if (indexPath.row == 1) {
            // is forked
            static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
            
            GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            GHAPIRepositoryV3 *repository = self.repository.source;
            
            cell.textLabel.text = repository.fullRepositoryName;
            cell.detailTextLabel.text = repository.description;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionLabels) {
        NSString *CellIdentifier = @"GHLabelTableViewCell";
        
        GHPLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHPLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = label.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionRecentCommits || indexPath.section == kUITableViewSectionBrowseContent) {
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = branch.name;
        
        return cell;
    } else if (indexPath.section == KUITableViewSectionREADME) {
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        
        cell.textLabel.text = NSLocalizedString(@"README", @"");
        cell.imageView.image = [UIImage imageNamed:@"GHFile.png"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return [GHPInfoTableViewCell heightWithContent:self.repository.description];
        } else if (indexPath.row == 1) {
            return [GHPInfoTableViewCell heightWithContent:self.metaInformationString];
        }
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            return 66.0f;
        } else if (indexPath.row == 1) {
            return [GHPRepositoryTableViewCell heightWithContent:self.repository.source.description];
        }
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            viewController = [[GHPUserViewController alloc] initWithUsername:self.repository.owner.login ];
        } else if (indexPath.row == 1) {
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:self.repository.source.fullRepositoryName];
        }
    } else if (indexPath.section == kUITableViewSectionFurtherContent) {
        if (indexPath.row == 3) {
            viewController = [[GHPWatchingRepositoryUsersViewController alloc] initWithRepository:self.repositoryString];
        } else if (indexPath.row == 2) {
            viewController = [[GHPCollaboratorsViewController alloc] initWithRepository:self.repositoryString];
        } else if (indexPath.row == 0) {
            viewController = [[GHPOpenIssuesOnRepositoryViewController alloc] initWithRepository:self.repositoryString];
        } else if (indexPath.row == 1) {
            viewController = [[GHPMileStonesOnRepositoryViewController alloc] initWithRepository:self.repositoryString];
        } else if (indexPath.row == 4) {
            viewController = [[GHPPullRequestsOnRepositoryViewController alloc] initWithRepository:self.repositoryString];
        } else if (indexPath.row == 5) {
            NSURL *repoURL = [NSURL URLWithString:self.repository.HTMLURL];
            NSURL *wikiURL = [repoURL URLByAppendingPathComponent:@"wiki"];
            viewController = [[GHWebViewViewController alloc] initWithURL:wikiURL];
            viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
        }
    } else if (indexPath.section == kUITableViewSectionRecentCommits) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        viewController = [[GHPCommitsViewController alloc] initWithRepository:self.repositoryString 
                                                                    branchHash:branch.ID];
    } else if (indexPath.section == kUITableViewSectionBrowseContent) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        viewController = [[GHPRootDirectoryViewController alloc] initWithRepository:self.repositoryString 
                                                                              branch:branch.name 
                                                                                hash:branch.ID];
    } else if (indexPath.section == kUITableViewSectionLabels) {
        GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row-1];
        viewController = [[GHPLabelViewController alloc] initWithRepository:self.repositoryString 
                                                                       label:label];
    } else if (indexPath.section == KUITableViewSectionREADME) {
        viewController = [[GHViewREADMEViewController alloc] initWithRepository:self.repositoryString];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagAction) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Watch", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHAPIRepositoryV3 watchRepository:self.repositoryString completionHandler:^(NSError *error) {
                self.infoCell.actionButton.alpha = 1.0f;
                [self.infoCell.activityIndicatorView stopAnimating];
                if (error) {
                    [self handleError:error];
                } else {
                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Now watching", @"") message:self.repositoryString];
                    _isWatchingRepository = YES;
                }
            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Unwatch", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHAPIRepositoryV3 unwatchRepository:self.repositoryString completionHandler:^(NSError *error) {
                self.infoCell.actionButton.alpha = 1.0f;
                [self.infoCell.activityIndicatorView stopAnimating];
                if (error) {
                    [self handleError:error];
                } else {
                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Stopped watching", @"") message:self.repositoryString];
                    _isWatchingRepository = NO;
                }
            }];
        } else if ([title isEqualToString:NSLocalizedString(@"View Homepage in Safari", @"")]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.repository.homepage] ];
        } else if ([title isEqualToString:NSLocalizedString(@"Delete Repository", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHRepository deleteTokenForRepository:self.repositoryString 
                             withCompletionHandler:^(NSString *deleteToken, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     self.deleteToken = deleteToken;
                                     
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete %@", @""), self.repositoryString] 
                                                                                      message:[NSString stringWithFormat:NSLocalizedString(@"Are you absolutely sure that you want to delete %@? This action can't be undone!", @""), self.repositoryString] 
                                                                                     delegate:self 
                                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                                            otherButtonTitles:NSLocalizedString(@"Delete", @""), nil];
                                     alert.tag = kUIAlertViewTagDeleteRepository;
                                     [alert show];
                                 }
                             }];
        } else if ([title isEqualToString:NSLocalizedString(@"Add Collaborator", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Collaborator", @"") 
                                                             message:nil 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Add", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewTagAddCollaborator;
            [alert show];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork to my Account", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHAPIRepositoryV3 forkRepository:self.repositoryString 
                               toOrganization:nil 
                            completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                                self.infoCell.actionButton.alpha = 1.0f;
                                [self.infoCell.activityIndicatorView stopAnimating];
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully forked", @"") message:self.repositoryString];
                                }
                            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork to an Organization", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHAPIOrganizationV3 organizationsOfUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       
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
                                               
                                               sheet.delegate = self;
                                               sheet.tag = kUIActionSheetTagSelectOrganization;
                                               
                                               [sheet showInView:self.parentViewController.view];
                                           }
                                       } else {
                                           self.infoCell.actionButton.alpha = 1.0f;
                                           [self.infoCell.activityIndicatorView stopAnimating];
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                            message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                  otherButtonTitles:nil];
                                           [alert show];
                                       }
                                       
                                   }];
        } else if ([title isEqualToString:NSLocalizedString(@"New Issue", @"")]) {
            GHPCreateIssueViewController *createViewController = [[GHPCreateIssueViewController alloc] initWithRepository:self.repositoryString delegate:self];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createViewController];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    } else if (actionSheet.tag == kUIActionSheetTagSelectOrganization) {
        if (buttonIndex < actionSheet.numberOfButtons - 1) {
            [self organizationsActionSheetDidSelectOrganizationAtIndex:buttonIndex];
        }
    }
}

- (void)organizationsActionSheetDidSelectOrganizationAtIndex:(NSUInteger)index {
    GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:index];
    
    [GHAPIRepositoryV3 forkRepository:self.repositoryString 
                       toOrganization:organization.login 
                    completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                        self.infoCell.actionButton.alpha = 1.0f;
                        [self.infoCell.activityIndicatorView stopAnimating];
                        if (error) {
                            [self handleError:error];
                        } else {
                            [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Forked Repository to", @"") message:organization.login];
                        }
                    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagDeleteRepository) {
        if (buttonIndex == 1) {
            [GHRepository deleteRepository:self.repositoryString 
                                 withToken:self.deleteToken 
                         completionHandler:^(NSError *error) {
                             self.actionButtonActive = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self.advancedNavigationController popViewController:self animated:YES];
                             }
                         }];
        } else {
            self.actionButtonActive = NO;
        }
    } else if (alertView.tag == kUIAlertViewTagAddCollaborator) {
        if (buttonIndex == 1) {
            NSString *username = [alertView textFieldAtIndex:0].text;
            [GHAPIRepositoryV3 addCollaboratorNamed:username 
                                       onRepository:self.repositoryString 
                                  completionHandler:^(NSError *error) {
                                      self.actionButtonActive = NO;
                                      if (error) {
                                          [self handleError:error];
                                      } else {
                                          [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Added Collaborator", @"") message:username];
                                      }
                                  }];
        } else {
            self.actionButtonActive = NO;
        }
    }
}

#pragma mark - GHPCreateIssueViewControllerDelegate

- (void)createIssueViewControllerIsDone:(GHPCreateIssueViewController *)createIssueViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createIssueViewController:(GHPCreateIssueViewController *)createIssueViewController didCreateIssue:(GHAPIIssueV3 *)issue {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Issue", @"") message:issue.title];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ActionMenu

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
    
    NSUInteger index = 0;
    
    if (!self.canAdministrateRepository) {
        if (!_isWatchingRepository) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Watch", @"")];
            index++;
        } else {
            index++;
            [sheet addButtonWithTitle:NSLocalizedString(@"Unwatch", @"")];
        }
    }
    index++;
    [sheet addButtonWithTitle:NSLocalizedString(@"New Issue", @"")];
    if (self.repository.hasHomepage) {
        index++;
        [sheet addButtonWithTitle:NSLocalizedString(@"View Homepage in Safari", @"")];
    }
    if (self.canAdministrateRepository) {
        index++;
        [sheet addButtonWithTitle:NSLocalizedString(@"Add Collaborator", @"")];
        [sheet addButtonWithTitle:NSLocalizedString(@"Delete Repository", @"")];
        [sheet setDestructiveButtonIndex:index];
    } else {
        [sheet addButtonWithTitle:NSLocalizedString(@"Fork to my Account", @"")];
        [sheet addButtonWithTitle:NSLocalizedString(@"Fork to an Organization", @"")];
    }
    if (sheet.numberOfButtons == 0) {
        return nil;
    }
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagAction;
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)canDisplayActionButtonActionSheet {
    return _hasWatchingData;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repositoryString forKey:@"repositoryString"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_deleteToken forKey:@"deleteToken"];
    [encoder encodeObject:_organizations forKey:@"organizations"];
    [encoder encodeBool:_hasWatchingData forKey:@"hasWatchingData"];
    [encoder encodeBool:_isWatchingRepository forKey:@"isWatchingRepository"];
    [encoder encodeObject:_labels forKey:@"labels"];
    [encoder encodeObject:_branches forKey:@"branches"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repositoryString = [decoder decodeObjectForKey:@"repositoryString"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _deleteToken = [decoder decodeObjectForKey:@"deleteToken"];
        _organizations = [decoder decodeObjectForKey:@"organizations"];
        _hasWatchingData = [decoder decodeBoolForKey:@"hasWatchingData"];
        _isWatchingRepository = [decoder decodeBoolForKey:@"isWatchingRepository"];
        _labels = [decoder decodeObjectForKey:@"labels"];
        _branches = [decoder decodeObjectForKey:@"branches"];
    }
    return self;
}

@end
