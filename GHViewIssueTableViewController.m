//
//  GHViewIssueTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewIssueTableViewController.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "GHIssueTitleTableViewCell.h"
#import "GHIssueDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHIssueCommentTableViewCell.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHNewCommentTableViewCell.h"
#import "GHUserViewController.h"
#import "GHSingleRepositoryViewController.h"
#import "GHMilestoneTableViewCell.h"
#import "GHViewPullRequestViewController.h"

#define kUITableViewSectionData             0
#define kUITableViewSectionPullRequest      1
#define kUITableViewSectionComments         2
#define kUITableViewSectionAdministration   3

@implementation GHViewIssueTableViewController

@synthesize issue=_issue;
@synthesize repository=_repository, number=_number;
@synthesize comments=_comments;
@synthesize textView=_textView, textViewToolBar=_textViewToolBar;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repository = repository;
        self.number = number;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), self.number];
        _isDownloadingIssueData = YES;
        [GHRepository collaboratorsForRepository:self.repository 
                               completionHandler:^(NSArray *collaborators, NSError *error) {
                                   if (!error) {
                                       NSString *myUsername = [GHSettingsHelper username];
                                       for (NSString *collaborator in collaborators) {
                                           if ([collaborator isEqualToString:myUsername]) {
                                               _canUserAdministrateIssue = YES;
                                               break;
                                           }
                                       }
                                       [self downloadIssueData];
                                   } else {
                                       [self handleError:error];
                                   }
                               }];
    }
    return self;
}

#pragma mark - instance methods

- (void)downloadIssueData {
    
    [GHIssueV3 issueOnRepository:self.repository withNumber:self.number completionHandler:^(GHIssueV3 *issue, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.issue = issue;
            _isDownloadingIssueData = NO;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_issue release];
    [_repository release];
    [_number release];
    [_comments release];
    [_textView release];
    [_textViewToolBar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [GHIssue postComment:self.textView.text forIssueOnRepository:self.repository 
              withNumber:self.number 
       completionHandler:^(GHIssueComment *comment, NSError *error) {
           if (error) {
               [self handleError:error];
           } else {
               NSMutableArray *commentsArray = [[self.comments mutableCopy] autorelease];
               [commentsArray addObject:comment];
               self.comments = commentsArray;
               
               self.issue.comments = [NSNumber numberWithInt:[self.issue.comments intValue] + 1];
               
               [self.tableView beginUpdates];
               
               [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count]+1 inSection:1]] withRowAnimation:UITableViewScrollPositionBottom];
               [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count] inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
               
               [self.tableView endUpdates];
               
               self.textView.text = nil;
           }
       }];
}

- (void)titleTableViewCellLongPressRecognized:(UILongPressGestureRecognizer *)recognizer {
    // TODO: support editing here in the future
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Edit this Issue", @"") 
//                                                            delegate:self 
//                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
//                                              destructiveButtonTitle:nil 
//                                                   otherButtonTitles:NSLocalizedString(@"Edit", @""), nil]
//                                autorelease];
//        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        [sheet showInView:self.tabBarController.view];
//    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textViewToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
    self.textViewToolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(toolbarCancelButtonClicked:)]
                             autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:@selector(noAction)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", @"") 
                                             style:UIBarButtonItemStyleDone 
                                            target:self 
                                            action:@selector(toolbarDoneButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    self.textViewToolBar.items = items;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.textView = nil;
    self.textViewToolBar = nil;
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
    if (_isDownloadingIssueData) {
        return NO;
    }
    return section != kUITableViewSectionData && section != kUITableViewSectionPullRequest;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionComments) {
        return self.comments == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == kUITableViewSectionComments) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Comments (%@)", @""), self.issue.comments];
    } else if (section == kUITableViewSectionAdministration) {
        cell.textLabel.text = NSLocalizedString(@"Administration", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionComments) {
        [GHIssue commentsForIssueOnRepository:self.repository 
                                   withNumber:self.number 
                            completionHandler:^(NSArray *comments, NSError *error) {
                                if (!error) {
                                    self.comments = comments;
                                    [tableView expandSection:section animated:YES];
                                } else {
                                    [tableView cancelDownloadInSection:section];
                                    [self handleError:error];
                                }
                            }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger result = 0;
    
    if (_isDownloadingIssueData) {
        result = 1;
    } else {
        // section
        //  0: the issue itself
        //  1: comments
        //  2: administrate
        result = 4;
        
        if (_canUserAdministrateIssue) {
            result++;
        }
    }
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = 0;
    
    if (_isDownloadingIssueData) {
        result = 1;
    } else {
        if (section == kUITableViewSectionData) {
            // the issue itself
            // title, description, number of votes
            // assigned to
            // milestone
            result = 4;
        } else if (section == kUITableViewSectionComments) {
            // we display our comment
            // first cell = Comments (5)
            // then all cells with the comments
            // then a cell to write a new comment
            result = [self.issue.comments intValue] + 2;
        } else if (section == kUITableViewSectionAdministration) {
            // first will be administrate
            result = 2;
        } else if (section == kUITableViewSectionPullRequest) {
            return self.issue.pullRequestID == nil ? 0 : 1;
        }
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isDownloadingIssueData) {
        NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
        
        UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = NSLocalizedString(@"Downloading Issue Data", @"");
        
        [cell setSpinning:YES];
        
        return cell;
    }
    
    if (indexPath.section == kUITableViewSectionData) {
        // the issue itself
        if (indexPath.row == 0) {
            // the title
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                
                if (_canUserAdministrateIssue) {
                    UILongPressGestureRecognizer *recognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(titleTableViewCellLongPressRecognized:)] autorelease];
                    recognizer.minimumPressDuration = 1.0;
                    
                    [cell addGestureRecognizer:recognizer];
                }
            }
            
            cell.textLabel.text = self.issue.title;
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:self.issue.user.gravatarID];
            
            NSDate *date = self.issue.createdAt.dateFromGithubAPIDateString;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", self.issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow] ];
            ;
            
            cell.descriptionLabel.text = self.issue.body;
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            cell.detailTextLabel.text = self.repository;
            cell.textLabel.text = NSLocalizedString(@"Repository", @"");
            
            return cell;
        } else if (indexPath.row == 2) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (self.issue.assignee.login) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
                cell.detailTextLabel.text = self.issue.assignee.login;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.detailTextLabel.text = @"No one is assigned";
            }
            
            cell.textLabel.text = NSLocalizedString(@"Assigned to", @"");
            
            return cell;
        } else if (indexPath.row == 3) {
            if (self.issue.milestone.title) {
                NSString *CellIdentifier = @"MilestoneCell";
                
                GHMilestoneTableViewCell *cell = (GHMilestoneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[[GHMilestoneTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                GHMilestone *milestone = self.issue.milestone;
                
                cell.textLabel.text = milestone.title;
                cell.detailTextLabel.text = milestone.dueFormattedString;
                cell.progressView.progress = [milestone.closedIssues floatValue] / ([milestone.closedIssues floatValue] + [milestone.openIssues floatValue]);
                
                if (milestone.dueInTime) {
                    [cell.progressView setTintColor:[UIColor greenColor] ];
                } else {
                    [cell.progressView setTintColor:[UIColor redColor] ];
                }
                
                return cell;
            } else {
                NSString *CellIdentifier = @"DetailsTableViewCell";
                
                UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.textLabel.text = NSLocalizedString(@"Milestone", @"");
                cell.detailTextLabel.text = @"No milestone";
                
                return cell;
            }
        }

    } else if (indexPath.section == kUITableViewSectionComments) {
        // comments
        if (indexPath.row >= 1 && indexPath.row <= [self.issue.comments intValue]) {
            // display a comment
            GHIssueComment *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:comment.gravatarID];
            
            NSDate *date = comment.updatedAt.dateFromGithubAPIDateString;
            
            cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), comment.user, date.prettyTimeIntervalSinceNow];
            
            cell.descriptionLabel.text = comment.body;
            
            return cell;
        } else if (indexPath.row == [self.issue.comments intValue] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:[GHSettingsHelper gravatarID]];
            
            cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHSettingsHelper username]];
            
            self.textView = cell.textView;
            cell.textView.inputAccessoryView = self.textViewToolBar;
            self.textView.scrollsToTop = NO;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAdministration) {
        // administrate
        if (indexPath.row == 1) {
            // open/ close
            
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if ([self.issue.state isEqualToString:@"open"]) {
                cell.textLabel.text = NSLocalizedString(@"Close this Issue", @"");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Reopen this Issue", @"");
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPullRequest) {
        NSString *CellIdentifier = @"kUITableViewSectionPullRequestCell";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = NSLocalizedString(@"View attatched Pull Request", @"");
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0f;
    
    if (_isDownloadingIssueData) {
        return result;
    }
    
    if (indexPath.section == kUITableViewSectionData) {
        if (indexPath.row == 0) {
            // the issues title
            
            CGSize bodySize = [self.issue.body sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                          constrainedToSize:CGSizeMake(222.0, MAXFLOAT) 
                                              lineBreakMode:UILineBreakModeWordWrap];
            
            result = bodySize.height + 50.0;
            
            if (result < 71.0) {
                result = 71.0;
            }
            
        } else if (indexPath.row == 1) {
            // the description
            return 44.0f;
        } else if (indexPath.row == 3) {
            return GHMilestoneTableViewCellHeight;
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        if (indexPath.row >= 1 && indexPath.row <= [self.issue.comments intValue]) {
            // we are going to display a comment
            GHIssueComment *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            CGSize size = [comment.body sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                   constrainedToSize:CGSizeMake(222.0, MAXFLOAT) 
                                       lineBreakMode:UILineBreakModeWordWrap];
            
            result = size.height + 50.0;
            
            if (result < 71.0) {
                result = 71.0;
            }
            
        } else if (indexPath.row == [self.issue.comments intValue] + 1) {
            result = 161.0;
        }
    }
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionAdministration) {
        if (indexPath.row == 1) {
            if ([self.issue.state isEqualToString:@"open"]) {
                [GHIssue closeIssueOnRepository:self.repository 
                                     withNumber:self.number 
                              completionHandler:^(NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.issue.state = @"closed";
                                      [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:kUITableViewSectionAdministration]] 
                                                            withRowAnimation:UITableViewRowAnimationFade];
                                  }
                              }];
            } else {
                [GHIssue reopenIssueOnRepository:self.repository 
                                      withNumber:self.number 
                               completionHandler:^(NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       self.issue.state = @"open";
                                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:kUITableViewSectionAdministration]] 
                                                             withRowAnimation:UITableViewRowAnimationFade];
                                   }
                               }];
            }
        }
    } else if (indexPath.section == kUITableViewSectionData) {
        if (indexPath.row == 0) {
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.issue.user.login] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if (indexPath.row == 1) {
            GHSingleRepositoryViewController *repoViewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:self.repository] autorelease];
            [self.navigationController pushViewController:repoViewController animated:YES];
        } else if (indexPath.row == 2 && self.issue.assignee.login) {
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.issue.assignee.login] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        if (indexPath.row >= 1 && indexPath.row <= [self.issue.comments intValue]) {
            // display a comment
            GHIssueComment *comment = [self.comments objectAtIndex:indexPath.row - 1];
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:comment.user] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionPullRequest) {
        GHViewPullRequestViewController *pullViewController = [[[GHViewPullRequestViewController alloc] initWithRepository:self.repository issueNumber:self.issue.pullRequestID] autorelease];
        [self.navigationController pushViewController:pullViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
