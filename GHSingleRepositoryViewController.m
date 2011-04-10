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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!self.repository) {
        return 0;
    }
    
    // sections:
    // 0 title + description
    // 1: issues
    // 2: watching
    // 3: administration
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        // title + description
        // + details (Created, Language, Size, Owner, Homepage, forked)
        return 7;
    } else if (section == 1) {
        // issues
        if (![self.repository.hasIssues boolValue]) {
            return 0;
        }
        NSInteger result = 1;
        if (_isShowingIssues) {
            result += [self.issuesArray count] + 1;
        }
        return result;
    } else if (section == 2) {
        NSInteger result = 1;
        if (_isShowingWatchedUsers) {
            result += [self.watchedUsersArray count];
        }
        return result;
    } else if (section == 3) {
        NSInteger result = 1;
        if (_isShowingAdminsitration) {
            result += 1;
        }
        return result;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
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
    } else if (indexPath.section == 1) {
        // issues
        if (indexPath.row == 0) {
            // Issues (X)
            NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
            
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues (%@)", @""), self.repository.openIssues];
            
            if (_isDownloadIssues) {
                [cell setSpinning:YES];
            } else {
                [cell setSpinning:NO];
                if (!_isShowingIssues) {
                    cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                } else {
                    cell.accessoryView.transform = CGAffineTransformIdentity;
                }
            }
            
            return cell;
        } else if (indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
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
    } else if (indexPath.section == 2) {
        // watching users
        if (indexPath.row == 0) {
            NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
            
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Watching Users (%@)", @""), self.repository.watchers];
            
            if (_isDownloadingWatchedUsers) {
                [cell setSpinning:YES];
            } else {
                [cell setSpinning:NO];
                if (!_isShowingWatchedUsers) {
                    cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                } else {
                    cell.accessoryView.transform = CGAffineTransformIdentity;
                }
            }
            
            return cell;
        } else if (indexPath.row > 0 && indexPath.row <= [self.watchedUsersArray count]) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }

            
            GHUser *user = [self.watchedUsersArray objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = user.login;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == 3) {
        // adminsitration
        if (indexPath.row == 0) {
            NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
            
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Administration", @"");
            
            [cell setSpinning:NO];
            if (!_isShowingAdminsitration) {
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            } else {
                cell.accessoryView.transform = CGAffineTransformIdentity;
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            // first administration
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if (self.canDeleteRepository) {
                cell.textLabel.text = NSLocalizedString(@"Delete this Repository", @"");
            } else {
                cell.textLabel.text = @"Watch/unwatch";
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
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // title + description
        if (![self isHeightCachedForRowAtIndexPath:indexPath]) {
            [self cacheHeight:[self heightForDescription:self.repository.desctiptionRepo] + 50.0 
            forRowAtIndexPath:indexPath];
        }
        
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1 && indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    
    return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 5 && ![self.repository.homePage isEqualToString:@""]) {
        NSURL *URL = [NSURL URLWithString:self.repository.homePage];
        
        GHWebViewViewController *webViewController = [[[GHWebViewViewController alloc] initWithURL:URL] autorelease];
        [self.navigationController pushViewController:webViewController animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 6 && self.repository.source) {
        GHSingleRepositoryViewController *repoViewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:self.repository.source] autorelease];
        repoViewController.delegate = self;
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (!self.issuesArray) {
            [self downloadIssues];
        } else {
            if (_isShowingIssues) {
                [self hideIssues];
            } else {
                [self showIssues];
            }
        }
    } else if (indexPath.section == 1 && indexPath.row > 0 && indexPath.row <= [self.issuesArray count]) {
        GHRawIssue *issue = [self.issuesArray objectAtIndex:indexPath.row-1];
        GHViewIssueTableViewController *issueViewController = [[[GHViewIssueTableViewController alloc] 
                                                                initWithRepository:self.repositoryString 
                                                                issueNumber:issue.number]
                                                               autorelease];
        [self.navigationController pushViewController:issueViewController animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        if (!self.watchedUsersArray) {
            [self downloadWatchedUsers];
        } else {
            if (_isShowingWatchedUsers) {
                [self hideWatchedUsers];
            } else {
                [self showWatchedUsers];
            }
        }
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        if (_isShowingAdminsitration) {
            [self hideAdminsitration];
        } else {
            [self showAdminsitration];
        }

    } else if (indexPath.section == 3 && indexPath.row == 1) {
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

#pragma mark - issue management

- (void)showIssues {
    _isShowingIssues = YES;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.repository.openIssues intValue]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    [newArray addObject:[NSIndexPath indexPathForRow:[self.repository.openIssues intValue]+1 inSection:1]];
    
    [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideIssues {
    _isShowingIssues = NO;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.repository.openIssues intValue]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    [newArray addObject:[NSIndexPath indexPathForRow:[self.repository.openIssues intValue]+1 inSection:1]];
    
    [self.tableView deleteRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
}

- (void)downloadIssues {
    _isDownloadIssues = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    [GHIssue openedIssuesOnRepository:self.repositoryString 
                    completionHandler:^(NSArray *issues, NSError *error) {
                        _isDownloadIssues = NO;
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
                        
                        if (error) {
                            [self handleError:error];
                        } else {
                            self.issuesArray = issues;
                            [self cacheHeightForIssuesArray];
                            [self showIssues];
                        }
                    }];
}

- (void)cacheHeightForIssuesArray {
    NSInteger i = 1;
    for (GHRawIssue *issue in self.issuesArray) {
        
        [self cacheHeight:[self heightForDescription:issue.title]+50.0f forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] ];
        
        i++;
    }
}

#pragma mark - watched users

- (void)showWatchedUsers {
    _isShowingWatchedUsers = YES;
    
    if ([self.watchedUsersArray count] > 10) {
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.watchedUsersArray count]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:2]];
    }
    
    [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideWatchedUsers {
    _isShowingWatchedUsers = NO;
    
    if ([self.watchedUsersArray count] > 10) {
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        return;
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.watchedUsersArray count]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:2]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
}

- (void)downloadWatchedUsers {
    _isDownloadingWatchedUsers = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] withRowAnimation:UITableViewRowAnimationNone];
    
    [GHRepository watchingUserOfRepository:self.repositoryString 
                     withCompletionHandler:^(NSArray *watchingUsers, NSError *error) {
                         _isDownloadingWatchedUsers = NO;
                         
                         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] withRowAnimation:UITableViewRowAnimationNone];
                         
                         if (error) {
                             [self handleError:error];
                         } else {
                             self.watchedUsersArray = watchingUsers;
                             [self showWatchedUsers];
                         }
                     }];
}

#pragma mark - administration

- (void)showAdminsitration {
    _isShowingAdminsitration = YES;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 1; i < [self tableView:self.tableView numberOfRowsInSection:3]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i inSection:3]];
    }
    
    [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideAdminsitration {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 1; i < [self tableView:self.tableView numberOfRowsInSection:3]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i inSection:3]];
    }
    
    _isShowingAdminsitration = NO;
    
    [self.tableView deleteRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
