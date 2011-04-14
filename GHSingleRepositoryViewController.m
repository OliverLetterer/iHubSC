//
//  GHSingleRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSingleRepositoryViewController.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "NSString+Additions.h"
#import "GHWebViewViewController.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHIssueTitleTableViewCell.h"
#import "GHViewIssueTableViewController.h"
#import "GHNewsFeedItemTableViewCell.h"
#import "GHUserViewController.h"

#define kUITableViewSectionUserData 0
#define kUITableViewSectionIssues 1
#define kUITableViewSectionWatchingUsers 2
#define kUITableViewSectionAdministration 3

@implementation GHSingleRepositoryViewController

@synthesize repositoryString=_repositoryString, repository=_repository, issuesArray=_issuesArray, watchedUsersArray=_watchedUsersArray, deleteToken=_deleteToken, delegate=_delegate;

#pragma mark - setters and getters

- (void)setRepositoryString:(NSString *)repositoryString {
    [_repositoryString release];
    _repositoryString = [repositoryString copy];
    [self reloadData];
}

- (BOOL)canDeleteRepository {
    return [self.repository.owner isEqualToString:[GHAuthenticationManager sharedInstance].username ];
}

- (BOOL)isFollowingRepository {
    return [self.watchedUsersArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[GHAuthenticationManager sharedInstance].username isEqualToString:obj]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] != NSNotFound;
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

#pragma mark - instance methods

- (void)reloadData {
    [GHRepository repository:self.repositoryString 
       withCompletionHandler:^(GHRepository *repository, NSError *error) {
           if (error) {
               [self handleError:error];
           } else {
               self.repository = repository;
               [self didReloadData];
               [self.tableView reloadData];
           }
       }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoryString release];
    [_repository release];
    [_issuesArray release];
    [_watchedUsersArray release];
    [_deleteToken release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section != 0;
}
- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionIssues) {
        return self.issuesArray == nil;
    } else if (section == kUITableViewSectionWatchingUsers) {
        return self.watchedUsersArray == nil;
    } else if (section == kUITableViewSectionAdministration) {
        if (!self.canDeleteRepository) {
            return self.watchedUsersArray == nil;
        }
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
    if (section == kUITableViewSectionIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues (%@)", @""), self.repository.openIssues];
    } else if (section == kUITableViewSectionWatchingUsers) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Watching Users (%@)", @""), self.repository.watchers];
    } else if (section == kUITableViewSectionAdministration) {
        cell.textLabel.text = self.canDeleteRepository ? NSLocalizedString(@"Administration", @"") : NSLocalizedString(@"Network", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionIssues) {
        [GHIssue openedIssuesOnRepository:self.repositoryString 
                        completionHandler:^(NSArray *issues, NSError *error) {
                            if (error) {
                                [tableView cancelDownloadInSection:section];
                                [self handleError:error];
                            } else {
                                self.issuesArray = issues;
                                [self cacheHeightForIssuesArray];
                                [tableView expandSection:section animated:YES];
                            }
                        }];
    } else if (section == kUITableViewSectionWatchingUsers) {
        [GHRepository watchingUserOfRepository:self.repositoryString 
                         withCompletionHandler:^(NSArray *watchingUsers, NSError *error) {
                             if (error) {
                                 [tableView cancelDownloadInSection:section];
                                 [self handleError:error];
                             } else {
                                 self.watchedUsersArray = [[watchingUsers mutableCopy] autorelease];
                                 [tableView expandSection:section animated:YES];
                             }
                         }];
    } else if (section == kUITableViewSectionAdministration) {
        [GHRepository watchingUserOfRepository:self.repositoryString 
                         withCompletionHandler:^(NSArray *watchingUsers, NSError *error) {
                             if (error) {
                                 [tableView cancelDownloadInSection:section];
                                 [self handleError:error];
                             } else {
                                 self.watchedUsersArray = [[watchingUsers mutableCopy] autorelease];
                                 [tableView expandSection:section animated:YES];
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
    
    // sections:
    // 0 title + description
    // 1: open issues
    // 2: watching
    // 3: administration
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionUserData) {
        // title + description
        // + details (Created, Language, Size, Owner, Homepage, forked)
        return 7;
    } else if (section == kUITableViewSectionIssues) {
        // issues
        // title, issues, create new issue
        return [self.issuesArray count] + 2;
    } else if (section == kUITableViewSectionWatchingUsers) {
        return [self.watchedUsersArray count] + 1;
    } else if (section == kUITableViewSectionAdministration) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 0) {
            // title + description
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if (self.repository.source) {
                cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", self.repository.owner, self.repository.name];
                cell.descriptionLabel.text = self.repository.desctiptionRepo;
                cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"forked from %@", @""), self.repository.source];
            } else {
                cell.titleLabel.text = self.repository.name;
                cell.descriptionLabel.text = self.repository.desctiptionRepo;
                cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created by %@", @""), self.repository.owner];
            }
            
            if ([self.repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            return cell;
        } else if (indexPath.row == 3) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDate *date = [self.repository.creationDate dateFromGithubAPIDateString];
            
            cell.textLabel.text = NSLocalizedString(@"Created", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow];
            
            
            return cell;
        } else if (indexPath.row == 2) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Language", @"");
            cell.detailTextLabel.text = self.repository.language;
            
            
            return cell;
        } else if (indexPath.row == 4) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Size", @"");
            cell.detailTextLabel.text = [NSString stringFormFileSize:[self.repository.size longLongValue] ];
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"DetailsOwnerTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Owner", @"");
            cell.detailTextLabel.text = self.repository.owner;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        } else if (indexPath.row == 5) {
            NSString *CellIdentifier = @"DetailsHomePageTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Homepage", @"");
            if ([self.repository.homePage isEqualToString:@""]) {
                cell.detailTextLabel.text = @"-";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.detailTextLabel.text = self.repository.homePage;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
            }
            
            return cell;
        } else if (indexPath.row == 6) {
            NSString *CellIdentifier = @"DetailsHomePageTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Forked from", @"");
            if (!self.repository.source) {
                cell.detailTextLabel.text = @"-";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.detailTextLabel.text = self.repository.source;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionIssues) {
        // issues
        if (indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHRawIssue *issue = [self.issuesArray objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:issue.gravatarID];
            
            NSDate *date = issue.creationDate.dateFromGithubAPIDateString;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@ (%@ votes)", issue.user, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow], issue.votes];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
            return cell;
        } else if (indexPath.row == [self.issuesArray count] + 1) {
            // new issue
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Create a new Issue", @"");
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionWatchingUsers) {
        // watching users
        if (indexPath.row > 0 && indexPath.row <= [self.watchedUsersArray count]) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = [self.watchedUsersArray objectAtIndex:indexPath.row - 1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAdministration) {
        // adminsitration
        if (indexPath.row == 1) {
            // first administration
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundViewAdmin";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if (self.canDeleteRepository) {
                cell.textLabel.text = NSLocalizedString(@"Delete this Repository", @"");
            } else {
                cell.textLabel.text = self.isFollowingRepository ? NSLocalizedString(@"Unfollow", @"") : NSLocalizedString(@"Follow", @"") ;
            }
            
            return cell;
        }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionUserData && indexPath.row == 0) {
        // title + description
        if (![self isHeightCachedForRowAtIndexPath:indexPath]) {
            [self cacheHeight:[self heightForDescription:self.repository.desctiptionRepo] + 50.0 
            forRowAtIndexPath:indexPath];
        }
        
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionIssues && indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    
    return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 1) {
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.repository.owner] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if (indexPath.row == 5 && ![self.repository.homePage isEqualToString:@""]) {
            NSURL *URL = [NSURL URLWithString:self.repository.homePage];
            
            GHWebViewViewController *webViewController = [[[GHWebViewViewController alloc] initWithURL:URL] autorelease];
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if (indexPath.row == 6 && self.repository.source) {
            GHSingleRepositoryViewController *repoViewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:self.repository.source] autorelease];
            repoViewController.delegate = self;
            [self.navigationController pushViewController:repoViewController animated:YES];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else if (indexPath.section == kUITableViewSectionIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
            GHRawIssue *issue = [self.issuesArray objectAtIndex:indexPath.row-1];
            GHViewIssueTableViewController *issueViewController = [[[GHViewIssueTableViewController alloc] 
                                                                    initWithRepository:self.repositoryString 
                                                                    issueNumber:issue.number]
                                                                   autorelease];
            [self.navigationController pushViewController:issueViewController animated:YES];
        } else {
            GHCreateIssueTableViewController *createViewController = [[[GHCreateIssueTableViewController alloc] initWithRepository:self.repositoryString] autorelease];
            createViewController.delegate = self;
            
            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:createViewController] autorelease];
            
            [self presentModalViewController:navController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionWatchingUsers) {
        // watched user
        NSString *user = [self.watchedUsersArray objectAtIndex:indexPath.row-1];
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewSectionAdministration) {
        if (indexPath.row == 1) {
            if (self.canDeleteRepository) {
                [GHRepository deleteTokenForRepository:self.repositoryString 
                                 withCompletionHandler:^(NSString *deleteToken, NSError *error) {
                                     [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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
                                         [alert show];
                                     }
                                 }];
            } else {
                if (self.isFollowingRepository) {
                    [GHRepository unfollowRepositorie:self.repositoryString completionHandler:^(NSError *error) {
                        if (error) {
                            [self handleError:error];
                        } else {
                            NSUInteger index = [self.watchedUsersArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                if ([[GHAuthenticationManager sharedInstance].username isEqualToString:obj]) {
                                    *stop = YES;
                                    return YES;
                                }
                                return NO;
                            }];
                            if (index != NSNotFound) {
                                [self.watchedUsersArray removeObjectAtIndex:index];
                                NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                                [set addIndex:kUITableViewSectionWatchingUsers];
                                [set addIndex:kUITableViewSectionAdministration];
                                [self.tableView reloadSections:set 
                                              withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    }];
                } else {
                    [GHRepository followRepositorie:self.repositoryString completionHandler:^(NSError *error) {
                        if (error) {
                            [self handleError:error];
                        } else {
                            NSUInteger index = [self.watchedUsersArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                if ([[GHAuthenticationManager sharedInstance].username isEqualToString:obj]) {
                                    *stop = YES;
                                    return YES;
                                }
                                return NO;
                            }];
                            if (index == NSNotFound) {
                                [self.watchedUsersArray addObject:[GHAuthenticationManager sharedInstance].username ];
                                NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                                [set addIndex:kUITableViewSectionWatchingUsers];
                                [set addIndex:kUITableViewSectionAdministration];
                                [self.tableView reloadSections:set 
                                              withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    }];
                }
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        self.view.userInteractionEnabled = NO;
        [GHRepository deleteRepository:self.repositoryString 
                             withToken:self.deleteToken 
                     completionHandler:^(NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             [self.delegate singleRepositoryViewControllerDidDeleteRepository:self];
                         }
                     }];
    }
}

- (void)cacheHeightForIssuesArray {
    NSInteger i = 1;
    for (GHRawIssue *issue in self.issuesArray) {
        [self cacheHeight:[self heightForDescription:issue.title]+50.0f forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] ];
        i++;
    }
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GHCreateIssueTableViewControllerDelegate

- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHRawIssue *)issue {
    self.issuesArray = nil;
    self.repository.openIssues = [NSNumber numberWithInt:[self.repository.openIssues intValue]+1 ];
    [self.tableView reloadData];
    [self.tableView expandSection:kUITableViewSectionIssues animated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
