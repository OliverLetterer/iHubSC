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
#import "UITableViewController+Additions.h"
#import "GHNewCommentTableViewCell.h"

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
    [GHIssue issueOnRepository:self.repository 
                    withNumber:self.number 
         useDatabaseIfPossible:NO 
             completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                 if (!error) {
                     self.issue = issue;
                     _isDownloadingIssueData = NO;
                     [self.tableView reloadData];
                 } else {
                     [self handleError:error];
                 }
             }];
}

- (void)downloadComments {
    _isDownloadingComments = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    [GHIssue commentsForIssueOnRepository:self.repository 
                               withNumber:self.number 
                        completionHandler:^(NSArray *comments, NSError *error) {
                            _isDownloadingComments = NO;
                            
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
                            
                            if (!error) {
                                self.comments = comments;
                                [self showComments];
                            } else {
                                [self handleError:error];
                            }
                        }];
}

- (void)showComments {
    _isShowingComments = YES;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.issue.comments intValue]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    [newArray addObject:[NSIndexPath indexPathForRow:[self.issue.comments intValue]+1 inSection:1]];
    
    [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideComments {
    _isShowingComments = NO;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (int i = 0; i < [self.issue.comments intValue]; i++) {
        [newArray addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    [newArray addObject:[NSIndexPath indexPathForRow:[self.issue.comments intValue]+1 inSection:1]];
    
    [self.tableView deleteRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationTop];
    
    [self.tableView endUpdates];
}

- (void)showAdministration {
    _isShowingAdministration = YES;
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2] ] 
                          withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] 
                          withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] 
                          atScrollPosition:UITableViewScrollPositionTop 
                                  animated:YES];
}

- (void)hideAdministration {
    _isShowingAdministration = NO;
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2] ] 
                          withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2] ] 
                          withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
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
    NSInteger result = 0;
    
    if (_isDownloadingIssueData) {
        result = 1;
    } else {
        // section
        //  0: the issue itself
        //  1: comments
        //  2: administrate
        result = 2;
        
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
        if (section == 0) {
            // the issue itself
            // title, description, number of votes
            result = 1;
        } else if (section == 1) {
            // we display our comment
            // first cell = Comments (5)
            // then all cells with the comments
            // then a cell to write a new comment
            result = 1;
            if (_isShowingComments) {
                result += [self.issue.comments intValue] + 1;
            }
        } else if (section == 2) {
            // first will be administrate
            result = 1;
            
            if (_isShowingAdministration) {
                // open / close
                result++;
            }
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
    
    if (indexPath.section == 0) {
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
                          withGravatarID:self.issue.gravatarID];
            
            NSDate *date = self.issue.creationDate.dateFromGithubAPIDateString;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@ (%@ votes)", self.issue.user, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow], self.issue.votes];
            ;
            
            cell.descriptionLabel.text = self.issue.body;
            
            return cell;
        }
    } else if (indexPath.section == 1) {
        // comments
        if (indexPath.row == 0) {
            // display comments header
            NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Comments (%@)", @""), self.issue.comments];
            
            if (_isDownloadingComments) {
                [cell setSpinning:YES];
            } else {
                [cell setSpinning:NO];
                if (!_isShowingComments) {
                    cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                } else {
                    cell.accessoryView.transform = CGAffineTransformIdentity;
                }
            }
            
            return cell;
        } else if (indexPath.row >= 1 && indexPath.row <= [self.issue.comments intValue]) {
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
    } else if (indexPath.section == 2) {
        // administrate
        if (indexPath.row == 0) {
            // Administrate cell
            NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            cell.textLabel.text = NSLocalizedString(@"Administrate", @"");
            [cell setSpinning:NO];
            
            if (!_isShowingAdministration) {
                cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            } else {
                cell.accessoryView.transform = CGAffineTransformIdentity;
            }
            
            return cell;
        } else if (indexPath.row == 1) {
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
    CGFloat result = 44.0;
    
    if (_isDownloadingIssueData) {
        return result;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // the issues title
            
            
            
            CGSize headerSize = [self.issue.title sizeWithFont:[UIFont boldSystemFontOfSize:11.0]
                                             constrainedToSize:CGSizeMake(220.0, MAXFLOAT) 
                                                 lineBreakMode:UILineBreakModeWordWrap];
            
            result = headerSize.height;
            
            CGSize bodySize = [self.issue.body sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                          constrainedToSize:CGSizeMake(222.0, MAXFLOAT) 
                                              lineBreakMode:UILineBreakModeWordWrap];
            
            result += bodySize.height + 30.0;
            
            if (result < 71.0) {
                result = 71.0;
            }
            
        } else if (indexPath.row == 1) {
            // the description
            CGSize size = [self.issue.body sizeWithFont:[UIFont systemFontOfSize:16.0] 
                                      constrainedToSize:CGSizeMake(300.0, MAXFLOAT) 
                                          lineBreakMode:UILineBreakModeWordWrap];
            
            result = size.height + 30.0;
        }
    } else if (indexPath.section == 1) {
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
    if (indexPath.section == 1) {
        if (_isDownloadingComments) {
            return;
        }
        if (indexPath.row == 0) {
            if (self.comments == nil) {
                [self downloadComments];
            } else {
                if (_isShowingComments) {
                    [self hideComments];
                } else {
                    [self showComments];
                }
            }
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (_isShowingAdministration) {
                [self hideAdministration];
            } else {
                [self showAdministration];
            }
        } else if (indexPath.row == 1) {
            if ([self.issue.state isEqualToString:@"open"]) {
                [GHIssue closeIssueOnRepository:self.repository 
                                     withNumber:self.number 
                              completionHandler:^(NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.issue.state = @"closed";
                                      [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] 
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
                                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] 
                                                             withRowAnimation:UITableViewRowAnimationFade];
                                   }
                               }];
            }
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
