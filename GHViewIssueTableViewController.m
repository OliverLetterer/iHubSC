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
#import "NSDate+Additions.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHIssueCommentTableViewCell.h"

@implementation GHViewIssueTableViewController

@synthesize issue=_issue;
@synthesize repository=_repository, number=_number;
@synthesize comments=_comments;

#pragma mark - setters and getters

- (UITableViewCell *)dummyCell {
    static NSString *CellIdentifier = @"DummyCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repository = repository;
        self.number = number;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), self.number];
        _isDownloadingIssueData = YES;
        [GHRepository collaboratorsForRepository:self.repository 
                                        username:[GHSettingsHelper username] 
                                        password:[GHSettingsHelper password] 
                               completionHandler:^(NSArray *collaborators, NSError *error) {
                                   if (!error) {
                                       NSString *myUsername = [GHSettingsHelper username];
                                       for (NSString *collaborator in collaborators) {
                                           if ([collaborator isEqualToString:myUsername]) {
                                               _canUserAdministrateIssue = YES;
                                               break;
                                           }
                                       }
                                   }
                                   [self downloadIssueData];
                               }];
    }
    return self;
}

#pragma mark - instance methods

- (void)downloadIssueData {
    [GHIssue issueOnRepository:self.repository 
                    withNumber:self.number 
                 loginUsername:[GHSettingsHelper username] 
                      password:[GHSettingsHelper password]
         useDatabaseIfPossible:NO 
             completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                 if (!error) {
                     self.issue = issue;
                     _isDownloadingIssueData = NO;
                     [self.tableView reloadData];
                 } else {
                     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                      message:[error localizedDescription] 
                                                                     delegate:nil 
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                            otherButtonTitles:nil]
                                           autorelease];
                     [alert show];
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
    
    [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationBottom];
    
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

- (void)downloadComments {
    _isDownloadingComments = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    
    [GHIssue commentsForIssueOnRepository:self.repository 
                               withNumber:self.number 
                        completionHandler:^(NSArray *comments, NSError *error) {
                            _isDownloadingComments = NO;
                            
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
                            
                            if (comments) {
                                self.comments = comments;
                                [self showComments];
                            } else {
                                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                                 message:[error localizedDescription] 
                                                                                delegate:nil 
                                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                       otherButtonTitles:nil]
                                                      autorelease];
                                [alert show];
                            }
                        }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_issue release];
    [_repository release];
    [_number release];
    [_comments release];
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
        result = 2;
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
            result = 2;
        } else if (section == 1) {
            // we display our comment
            // first cell = Comments (5)
            // then all cells with the comments
            // then a cell to write a new comment
            result = 1;
            if (_isShowingComments) {
                result += [self.issue.comments intValue] + 1;
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
            }
            
            cell.textLabel.text = self.issue.title;
            
            NSString *lastUpdate = self.issue.creationDate;
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
            NSDate *date = [formatter dateFromString:lastUpdate];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@ (%@ votes)", self.issue.user, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow], self.issue.votes];
            ;            
            return cell;
        } else if (indexPath.row == 1) {
            // the issues description
            NSString *CellIdentifier = @"GHIssueDescriptionTableViewCell";
            GHIssueDescriptionTableViewCell *cell = (GHIssueDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = self.issue.body;
            
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
            GHIssueComment *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            NSString *CellIdentifier = @"GHIssueCommentTableViewCell";
            
            GHIssueCommentTableViewCell *cell = (GHIssueCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHIssueCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = comment.body;
            cell.detailTextLabel.text = comment.user;
            
            NSString *lastUpdate = comment.updatedAt;
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
            NSDate *date = [formatter dateFromString:lastUpdate];
            
            cell.timeDetailsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow];
            
            return cell;
        } else if (indexPath.row == [self.issue.comments intValue] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"UITableViewCellForNewIssue";
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            }
            
            cell.textLabel.text = NSLocalizedString(@"New Comment", @"");
            
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
            CGSize headerSize = [self.issue.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]
                                             constrainedToSize:CGSizeMake(280.0, MAXFLOAT) 
                                                 lineBreakMode:UILineBreakModeWordWrap];
            
            result = headerSize.height + 25.0;
            
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
            
            CGSize size = [comment.body sizeWithFont:[UIFont systemFontOfSize:17.0] 
                                   constrainedToSize:CGSizeMake(280.0, MAXFLOAT) 
                                       lineBreakMode:UILineBreakModeWordWrap];
            
            result = size.height + 38.0;
        }
    }
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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
    }
}

@end
