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

#define kUIAlertViewTagDeleteRepository     1337
#define kUIAlertViewTagAddCollaborator      1338

#define kUIActionSheetTagAction             1339
#define kUIActionSheetTagSelectOrganization 1340

#define kUITableViewSectionInfo             0
#define kUITableViewSectionOwner            1
#define kUITableViewSectionFurtherContent   2
#define kUITableViewSectionRecentCommits    3
#define kUITableViewSectionBrowseContent    4
#define kUITableViewSectionLabels           5

#define kUITableViewNumberOfSections        6

@implementation GHPRepositoryViewController

@synthesize repositoryString=_repositoryString, repository=_repository, deleteToken=_deleteToken, organizations=_organizations;
@synthesize infoCell=_infoCell;
@synthesize labels=_labels, branches=_branches;

#pragma mark - setters and getters

- (void)setRepositoryString:(NSString *)repositoryString {
    [_repositoryString release];
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
    return [self.repository.owner.login isEqualToString:[GHAuthenticationManager sharedInstance].username ];
}

- (UIActionSheet *)actionButtonActionSheet {
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
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

#pragma mark - Initialization

- (id)initWithRepositoryString:(NSString *)repositoryString {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repositoryString = repositoryString;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoryString release];
    [_repository release];
    [_infoCell release];
    [_deleteToken release];
    [_organizations release];
    [_labels release];
    [_branches release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_infoCell release], _infoCell = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
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
        return 5;
    } else if (section == kUITableViewSectionOwner) {
        if (self.repository.isForked) {
            return 2;
        }
        return 1;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels.count + 1;
    } else if (section == kUITableViewSectionRecentCommits || section == kUITableViewSectionBrowseContent) {
        return self.branches.count + 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHPInfoTableViewCellDelegate";
            GHPInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHPInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                              reuseIdentifier:CellIdentifier]
                        autorelease];
            }
            
            cell.textLabel.text = self.repository.fullRepositoryName;
            cell.detailTextLabel.text = self.repository.description;
            
            if ([self.repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            cell.delegate = self;
            
            self.infoCell = cell;
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"GHPInfoTableViewCellDelegate";
            GHPInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHPInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                              reuseIdentifier:CellIdentifier]
                        autorelease];
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
        } else {
            cell.textLabel.text = nil;
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHPUserTableViewCell";
            GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                    reuseIdentifier:CellIdentifier]
                        autorelease];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:self.repository.owner.gravatarID];
            cell.textLabel.text = self.repository.owner.login;
            
            return cell;
        } else if (indexPath.row == 1) {
            // is forked
            static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
            
            GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
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
            cell = [[[GHPLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
    }
    
    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    if (indexPath.section == kUITableViewSectionOwner) {
        UIViewController *viewController = nil;
        
        if (indexPath.row == 0) {
            viewController = [[[GHPUserViewController alloc] initWithUsername:self.repository.owner.login ] autorelease];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:self.repository.source.fullRepositoryName] autorelease];
        }
        
        if (viewController) {
            [self.advancedNavigationController pushViewController:viewController afterViewController:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else if (indexPath.section == kUITableViewSectionFurtherContent) {
        UIViewController *viewController = nil;
        
        if (indexPath.row == 3) {
            viewController = [[[GHPWatchingRepositoryUsersViewController alloc] initWithRepository:self.repositoryString] autorelease];
        } else if (indexPath.row == 2) {
            viewController = [[[GHPCollaboratorsViewController alloc] initWithRepository:self.repositoryString] autorelease];
        } else if (indexPath.row == 0) {
            viewController = [[[GHPOpenIssuesOnRepositoryViewController alloc] initWithRepository:self.repositoryString] autorelease];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPMileStonesOnRepositoryViewController alloc] initWithRepository:self.repositoryString] autorelease];
        } else if (indexPath.row == 4) {
            viewController = [[[GHPPullRequestsOnRepositoryViewController alloc] initWithRepository:self.repositoryString] autorelease];
        }
        
        if (viewController) {
            [self.advancedNavigationController pushViewController:viewController afterViewController:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else if (indexPath.section == kUITableViewSectionRecentCommits) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        GHPCommitsViewController *viewController = [[[GHPCommitsViewController alloc] initWithRepository:self.repositoryString 
                                                                                                    branchHash:branch.ID]
                                                          autorelease];
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    } else if (indexPath.section == kUITableViewSectionBrowseContent) {
        GHAPIRepositoryBranchV3 *branch = [self.branches objectAtIndex:indexPath.row - 1];
        
        GHPRootDirectoryViewController *viewController = [[[GHPRootDirectoryViewController alloc] initWithRepository:self.repositoryString 
                                                                                                              branch:branch.name 
                                                                                                                hash:branch.ID]
                                                          autorelease];
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    } else if (indexPath.section == kUITableViewSectionLabels) {
        GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row-1];
        GHPLabelViewController *viewController = [[[GHPLabelViewController alloc] initWithRepository:self.repositoryString 
                                                                                               label:label]
                                                  autorelease];
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
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
                    [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Now watching", @"") andSubtitle:self.repositoryString removeStyle:INNotificationQueueItemRemoveByFadingOut];
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
                    [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Stopped watching", @"") andSubtitle:self.repositoryString removeStyle:INNotificationQueueItemRemoveByFadingOut];
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
                                     
                                     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete %@", @""), self.repositoryString] 
                                                                                      message:[NSString stringWithFormat:NSLocalizedString(@"Are you absolutely sure that you want to delete %@? This action can't be undone!", @""), self.repositoryString] 
                                                                                     delegate:self 
                                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                                            otherButtonTitles:NSLocalizedString(@"Delete", @""), nil]
                                                           autorelease];
                                     alert.tag = kUIAlertViewTagDeleteRepository;
                                     [alert show];
                                 }
                             }];
        } else if ([title isEqualToString:NSLocalizedString(@"Add Collaborator", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Collaborator", @"") 
                                                             message:nil 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Add", @""), nil]
                                  autorelease];
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
                                    [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Successfully forked", @"") andSubtitle:self.repositoryString removeStyle:INNotificationQueueItemRemoveByFadingOut];
                                }
                            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork to an Organization", @"")]) {
            self.infoCell.actionButton.alpha = 0.0f;
            [self.infoCell.activityIndicatorView startAnimating];
            [GHAPIOrganizationV3 organizationsOfUser:[GHAuthenticationManager sharedInstance].username page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       
                                       self.organizations = array;
                                       
                                       if (self.organizations.count > 0) {
                                           if (self.organizations.count == 1) {
                                               // we only have one organization, act as if user select this only organization
                                               [self organizationsActionSheetDidSelectOrganizationAtIndex:0];
                                           } else {
                                               UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
                                               
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
                                           UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                            message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                  otherButtonTitles:nil]
                                                                 autorelease];
                                           [alert show];
                                       }
                                       
                                   }];
        } else if ([title isEqualToString:NSLocalizedString(@"New Issue", @"")]) {
            GHPCreateIssueViewController *createViewController = [[[GHPCreateIssueViewController alloc] initWithRepository:self.repositoryString delegate:self] autorelease];
            
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:createViewController] autorelease];
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
                            [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Forked Repository to", @"") andSubtitle:organization.login removeStyle:INNotificationQueueItemRemoveByFadingOut];
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
                             self.infoCell.actionButton.alpha = 1.0f;
                             [self.infoCell.activityIndicatorView stopAnimating];
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self.advancedNavigationController popViewController:self];
                             }
                         }];
        } else {
            self.infoCell.actionButton.alpha = 1.0f;
            [self.infoCell.activityIndicatorView stopAnimating];
        }
    } else if (alertView.tag == kUIAlertViewTagAddCollaborator) {
        if (buttonIndex == 1) {
            NSString *username = [alertView textFieldAtIndex:0].text;
            [GHAPIRepositoryV3 addCollaboratorNamed:username 
                                       onRepository:self.repositoryString 
                                  completionHandler:^(NSError *error) {
                                      self.infoCell.actionButton.alpha = 1.0f;
                                      [self.infoCell.activityIndicatorView stopAnimating];
                                      if (error) {
                                          [self handleError:error];
                                      } else {
                                          [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Added Collaborator", @"") andSubtitle:username removeStyle:INNotificationQueueItemRemoveByFadingOut];
                                      }
                                  }];
        } else {
            self.infoCell.actionButton.alpha = 1.0f;
            [self.infoCell.activityIndicatorView stopAnimating];
        }
    }
}

#pragma mark - GHPInfoTableViewCellDelegateDelegate

- (void)infoTableViewCellActionButtonClicked:(GHPInfoTableViewCell *)cell {
    if (!self.canAdministrateRepository && !_hasWatchingData) {
        cell.actionButton.alpha = 0.0f;
        [cell.activityIndicatorView startAnimating];
        [GHAPIRepositoryV3 isWatchingRepository:self.repositoryString 
                              completionHandler:^(BOOL watching, NSError *error) {
                                  cell.actionButton.alpha = 1.0f;
                                  [cell.activityIndicatorView stopAnimating];
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      _hasWatchingData = YES;
                                      _isWatchingRepository = watching;
                                      UIActionSheet *sheet = self.actionButtonActionSheet;
                                      
                                      [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                                                   inView:self.view 
                                                 animated:YES];
                                  }
                              }];
    } else {
        UIActionSheet *sheet = self.actionButtonActionSheet;
        
        [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                     inView:self.view 
                   animated:YES];
    }
}

#pragma mark - GHPCreateIssueViewControllerDelegate

- (void)createIssueViewControllerIsDone:(GHPCreateIssueViewController *)createIssueViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createIssueViewController:(GHPCreateIssueViewController *)createIssueViewController didCreateIssue:(GHAPIIssueV3 *)issue {
    [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Created Issue", @"") 
                                                            andSubtitle:issue.title 
                                                            removeStyle:INNotificationQueueItemRemoveByFadingOut];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
