//
//  GHViewPullRequestViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewPullRequestViewController.h"
#import "GHIssueTitleTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHNewCommentTableViewCell.h"
#import "GHSettingsHelper.h"
#import "GHViewCommitViewController.h"

@implementation GHViewPullRequestViewController

@synthesize repository=_repository, number=_number, discussion=_discussion;
@synthesize textView=_textView, textViewToolBar=_textViewToolBar;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.repository = repository;
        self.number = number;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Pull Request %@", @""), self.number];
        [self downloadDiscussionData];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_number release];
    [_discussion release];
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
               NSMutableArray *commentsArray = [[self.discussion.commentsArray mutableCopy] autorelease];
               [commentsArray addObject:comment];
               self.discussion.commentsArray = commentsArray;
               
               self.discussion.comments = [NSNumber numberWithInt:[self.discussion.comments intValue] + 1];
               
               [self.tableView beginUpdates];
               
               [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.discussion.commentsArray count]+1 inSection:1]] withRowAnimation:UITableViewScrollPositionBottom];
               [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.discussion.commentsArray count] inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
               
               [self.tableView endUpdates];
               
               self.textView.text = nil;
           }
       }];
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

#pragma mark - instance methods

- (void)downloadDiscussionData {
    [GHPullRequest pullRequestDiscussionOnRepository:self.repository 
                                              number:self.number 
                                   completionHandler:^(GHPullRequestDiscussion *discussion, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           self.discussion = discussion;
                                           [self.tableView reloadData];
                                       }
                                   }];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section != 0;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Comments (%@)", @""), self.discussion.comments];
    } else if (section == 2) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Commits (%d)", @""), [self.discussion.commits count]];
    }
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.discussion) {
        return 0;
    }
    // Return the number of sections.
    // 0: the pull requests description
    // 1: Comments
    // commits
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.discussion.comments intValue] + 2; // comments + header + new comment
    } else if (section == 2) {
        return [self.discussion.commits count] + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // the issue itself
        if (indexPath.row == 0) {
            // the title
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = self.discussion.title;
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:self.discussion.gravatarID];
            
            NSDate *date = self.discussion.updatedAt.dateFromGithubAPIDateString;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@ (%@ votes)", self.discussion.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), date.prettyTimeIntervalSinceNow], self.discussion.votes];
            ;
            
            cell.descriptionLabel.text = self.discussion.body;
            
            return cell;
        }
    } else if (indexPath.section == 1) {
        // comments
        if (indexPath.row >= 1 && indexPath.row <= [self.discussion.comments intValue]) {
            // display a comment
            GHIssueComment *comment = [self.discussion.commentsArray objectAtIndex:indexPath.row - 1];
            
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:comment.gravatarID];
            
            NSDate *date = comment.updatedAt.dateFromGithubAPIDateString;
            
            cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), comment.userInfo.login, date.prettyTimeIntervalSinceNow];
            
            cell.descriptionLabel.text = comment.body;
            
            return cell;
        } else if (indexPath.row == [self.discussion.comments intValue] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
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
        
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        [self updateImageViewForCell:cell 
                         atIndexPath:indexPath 
                      withGravatarID:commit.user.gravatarID];
        
        cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ committed %@", @""), commit.user.login, commit.ID];
        cell.descriptionLabel.text = commit.message;
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        // now we got a commit selected. show this beast
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        NSString *repo = [NSString stringWithFormat:@"%@/%@", self.discussion.head.repository.owner, self.discussion.head.repository.name];
        
        GHViewCommitViewController *commitViewController = [[[GHViewCommitViewController alloc] initWithRepository:repo
                                                                                                          commitID:commit.ID]
                                                            autorelease];
        [self.navigationController pushViewController:commitViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // the issues title
            
            CGFloat height = [self heightForDescription:self.discussion.body] + 50.0f;
            
            if (height < 71.0) {
                return 71.0;
            }
            
            return height;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row >= 1 && indexPath.row <= [self.discussion.comments intValue]) {
            // we are going to display a comment
            GHIssueComment *comment = [self.discussion.commentsArray objectAtIndex:indexPath.row - 1];
            
            CGFloat height = [self heightForDescription:comment.body] + 50.0f;
            
            if (height < 71.0) {
                return 71.0;
            }
            
            return height;
        } else if (indexPath.row == [self.discussion.comments intValue] + 1) {
            return 161.0;
        }
    } else if (indexPath.section == 2 && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row - 1];
        
        CGFloat height = [self heightForDescription:commit.message] + 50.0f;
        
        if (height < 71.0) {
            return 71.0;
        }
        
        return height;
    }
    
    return 44.0f;
}

@end
