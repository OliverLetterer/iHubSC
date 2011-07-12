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
#import "GHAPIMilestoneV3TableViewCell.h"
#import "GHViewCommitViewController.h"
#import "GHViewMilestoneViewController.h"
#import "GHLabelTableViewCell.h"
#import "GHViewLabelViewController.h"

#define kUITableViewSectionData             0
#define kUITableViewSectionAssignee         1
#define kUITableViewSectionMilestone        2
#define kUITableViewSectionCommits          3
#define kUITableViewSectionLabels           4
#define kUITableViewSectionHistory          5
#define kUITableViewSectionAdministration   6

#define kUITableViesNumberOfSections        7

@implementation GHViewIssueTableViewController

@synthesize issue=_issue;
@synthesize repository=_repository, number=_number;
@synthesize history=_history, discussion=_discussion;
@synthesize textView=_textView, textViewToolBar=_textViewToolBar;

#pragma mark - setters and getters

- (NSString *)issueName {
    if (self.issue.isPullRequest) {
        return NSLocalizedString(@"Pull Request", @"");
    } else {
        return NSLocalizedString(@"Issue", @"");
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repository = repository;
        self.number = number;
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), self.number];
        _isDownloadingIssueData = YES;
        
        [GHAPIRepositoryV3 isUser:[GHSettingsHelper username] 
         collaboratorOnRepository:self.repository 
                completionHandler:^(BOOL state, NSError *error) {
                    if (error) {
                        [self handleError:error];
                    } else {
                        _canUserAdministrateIssue = state;
                        [self downloadIssueData];
                    }
                }];
    }
    return self;
}

#pragma mark - instance methods

- (void)downloadIssueData {
    
    [GHAPIIssueV3 issueOnRepository:self.repository withNumber:self.number completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.issue = issue;
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), self.issueName, self.number];
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
    [_history release];
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
    [self.textView resignFirstResponder];
    
    [GHAPIIssueV3 postComment:self.textView.text 
      forIssueOnRepository:self.repository 
                withNumber:self.number 
         completionHandler:^(GHAPIIssueCommentV3 *comment, NSError *error) {
             if (error) {
                 [self handleError:error];
             } else {
                 NSMutableArray *tmpArray = [[self.history mutableCopy] autorelease];
                 [tmpArray addObject:comment];
                 self.history = tmpArray;
                 
                 self.issue.comments = [NSNumber numberWithInt:[self.issue.comments intValue] + 1];
                 
                 [self.tableView beginUpdates];
                 
                 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count]+1 inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count] inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 
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
    return section != kUITableViewSectionData && section != kUITableViewSectionMilestone && section != kUITableViewSectionAssignee;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionHistory) {
        return self.history == nil;
    } else if (section == kUITableViewSectionCommits) {
        return self.discussion == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == kUITableViewSectionAdministration) {
        cell.textLabel.text = NSLocalizedString(@"Administration", @"");
    } else if (section == kUITableViewSectionHistory) {
        cell.textLabel.text = NSLocalizedString(@"History", @"");
    } else if (section == kUITableViewSectionCommits) {
        cell.textLabel.text = NSLocalizedString(@"View attatched Commits", @"");
    } else if (section == kUITableViewSectionLabels) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Labels (%d)", @""), self.issue.labels.count];
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionHistory) {
        [GHAPIIssueV3 historyForIssueWithID:self.number onRepository:self.repository 
                          completionHandler:^(NSArray *history, NSError *error) {
                              if (!error) {
                                  self.history = history;
                                  [tableView expandSection:section animated:YES];
                              } else {
                                  [tableView cancelDownloadInSection:section];
                                  [self handleError:error];
                              }
                          }];
    } else if (section == kUITableViewSectionCommits) {
        [GHPullRequest pullRequestDiscussionOnRepository:self.repository 
                                                  number:self.number 
                                       completionHandler:^(GHPullRequestDiscussion *discussion, NSError *error) {
                                           if (error) {
                                               [self handleError:error];
                                               [tableView cancelDownloadInSection:section];
                                           } else {
                                               self.discussion = discussion;
                                               [tableView expandSection:section animated:YES];
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
        return kUITableViesNumberOfSections;
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
            // repository
            result = 2;
        } else if (section == kUITableViewSectionAssignee) {
            if (self.issue.hasAssignee) {
                return 1;
            }
        } else if (section == kUITableViewSectionMilestone) {
            if (self.issue.hasMilestone) {
                return 1;
            }
        } else if (section == kUITableViewSectionAdministration) {
            // first will be administrate
            if (!_canUserAdministrateIssue) {
                return 0;
            }
            result = 2;
        } else if (section == kUITableViewSectionHistory) {
            return self.history.count + 2;
        } else if (section == kUITableViewSectionCommits) {
            return self.issue.isPullRequest ? [self.discussion.commits count] + 1 : 0;
        } else if (section == kUITableViewSectionLabels) {
            if (self.issue.labels.count == 0) {
                return 0;
            }
            return self.issue.labels.count + 1;
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
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", self.issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), self.issue.createdAt.prettyTimeIntervalSinceNow] ];
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
        }
    } else if (indexPath.section == kUITableViewSectionAssignee) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            cell.detailTextLabel.text = self.issue.assignee.login;
            
            cell.textLabel.text = NSLocalizedString(@"Assigned to", @"");
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionMilestone) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"MilestoneCell";
            
            GHAPIMilestoneV3TableViewCell *cell = (GHAPIMilestoneV3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHAPIMilestoneV3TableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIMilestoneV3 *milestone = self.issue.milestone;
            
            cell.textLabel.text = milestone.title;
            cell.detailTextLabel.text = milestone.dueFormattedString;
            
            cell.progressView.progress = milestone.progress;
            
            if (milestone.dueInTime) {
                [cell.progressView setTintColor:[UIColor greenColor] ];
            } else {
                [cell.progressView setTintColor:[UIColor redColor] ];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
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
    } else if (indexPath.section == kUITableViewSectionHistory) {
        if (indexPath.row == [self.history count] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHSettingsHelper avatarURL]];
            
            cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHSettingsHelper username]];
            
            self.textView = cell.textView;
            cell.textView.inputAccessoryView = self.textViewToolBar;
            self.textView.scrollsToTop = NO;
            
            return cell;
        }
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;

            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on this %@", @""), comment.user.login, self.issueName];
            cell.descriptionLabel.text = comment.body;
            cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), comment.updatedAt.prettyTimeIntervalSinceNow];
            
            return cell;
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:event.actor.avatarURL];
            
            cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), event.createdAt.prettyTimeIntervalSinceNow];
            
            cell.descriptionLabel.text = nil;
            cell.titleLabel.text = nil;
            
            switch (event.type) {
                case GHAPIIssueEventTypeV3Closed:
                    ;
                    NSString *description = nil;
                    if (event.commitID) {
                        description = [NSString stringWithFormat:NSLocalizedString(@"%@ closed this %@ in", @""), event.actor.login, self.issueName];
                    } else {
                        description = [NSString stringWithFormat:NSLocalizedString(@"%@ closed this %@", @""), event.actor.login, self.issueName];
                    }
                    cell.titleLabel.text = description;
                    cell.descriptionLabel.text = event.commitID;
                    break;
                    
                case GHAPIIssueEventTypeV3Reopened:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ reopened this %@", @""), event.actor.login, self.issueName];
                    break;
                    
                case GHAPIIssueEventTypeV3Subscribed:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ subscribed to this %@", @""), event.actor.login, self.issueName];
                    break;
                    
                case GHAPIIssueEventTypeV3Merged:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ merged this %@ with", @""), event.actor.login, self.issueName];
                    cell.descriptionLabel.text = event.commitID;
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Referenced:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"This %@ was referenced in", @""), self.issueName];
                    cell.descriptionLabel.text = event.commitID;
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Mentioned:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ was mentioned in a body", @""), event.actor.login];
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Assigned:
                    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ was assigned to this %@", @""), event.actor.login, self.issueName];
                    
                    break;
                    
                default:
                    break;
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionCommits) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:commit.user.gravatarID];
        
        cell.titleLabel.text = commit.ID;
        cell.descriptionLabel.text = commit.message;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionLabels && indexPath.row > 0) {
        NSString *CellIdentifier = @"GHLabelTableViewCell";
        
        GHLabelTableViewCell *cell = (GHLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[GHLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPILabelV3 *label = [self.issue.labels objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = label.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
        
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
            return GHAPIMilestoneV3TableViewCellHeight;
        }
    } else if (indexPath.section == kUITableViewSectionHistory && indexPath.row > 0) {
        if (indexPath.row == [self.history count] + 1) {
            return 161.0f;
        }
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
            
            CGSize size = [comment.body sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                   constrainedToSize:CGSizeMake(222.0, MAXFLOAT) 
                                       lineBreakMode:UILineBreakModeWordWrap];
            
            result = size.height + 50.0;
            
            if (result < 71.0) {
                result = 71.0;
            }
            
            return result;
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            return 71.0f;
        }
    } else if (indexPath.section == kUITableViewSectionCommits && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row - 1];
        
        CGFloat height = [self heightForDescription:commit.message] + 50.0f;
        
        if (height < 71.0) {
            return 71.0;
        }
        
        return height;
    }
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionAdministration) {
        if (indexPath.row == 1) {
            if ([self.issue.state isEqualToString:@"open"]) {
                [GHAPIIssueV3 closeIssueOnRepository:self.repository 
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
                [GHAPIIssueV3 reopenIssueOnRepository:self.repository withNumber:self.number 
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
        }
    } else if (indexPath.section == kUITableViewSectionAssignee && indexPath.row == 0) {
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.issue.assignee.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionMilestone && indexPath.row == 0) {
        GHAPIMilestoneV3 *milestone = self.issue.milestone;
        GHViewMilestoneViewController *milestoneViewController = [[[GHViewMilestoneViewController alloc] initWithRepository:self.repository milestoneNumber:milestone.number] autorelease];
        [self.navigationController pushViewController:milestoneViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionHistory && indexPath.row > 0 && indexPath.row < [self.history count]+1) {
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:comment.user.login] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            UIViewController *nextViewController = nil;
            
            switch (event.type) {
                case GHAPIIssueEventTypeV3Closed:
                    if (event.commitID) {
                        nextViewController = [[[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID] autorelease];
                    } else {
                        nextViewController = [[[GHUserViewController alloc] initWithUsername:event.actor.login] autorelease];
                    }
                    break;
                    
                case GHAPIIssueEventTypeV3Reopened:
                    nextViewController = [[[GHUserViewController alloc] initWithUsername:event.actor.login] autorelease];
                    break;
                    
                case GHAPIIssueEventTypeV3Subscribed:
                    nextViewController = [[[GHUserViewController alloc] initWithUsername:event.actor.login] autorelease];
                    break;
                    
                case GHAPIIssueEventTypeV3Merged:
                    nextViewController = [[[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID] autorelease];
                    break;
                    
                case GHAPIIssueEventTypeV3Referenced:
                    nextViewController = [[[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID] autorelease];
                    break;
                    
                case GHAPIIssueEventTypeV3Mentioned:
                    nextViewController = [[[GHUserViewController alloc] initWithUsername:event.actor.login] autorelease];
                    break;
                    
                case GHAPIIssueEventTypeV3Assigned:
                    nextViewController = [[[GHUserViewController alloc] initWithUsername:event.actor.login] autorelease];
                    break;
                    
                default:
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
            }
            
            if (nextViewController) {
                [self.navigationController pushViewController:nextViewController animated:YES];
            }
        }

        
    } else if (indexPath.section == kUITableViewSectionCommits && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        NSString *repo = [NSString stringWithFormat:@"%@/%@", self.discussion.head.repository.owner, self.discussion.head.repository.name];
        
        GHViewCommitViewController *commitViewController = [[[GHViewCommitViewController alloc] initWithRepository:repo
                                                                                                          commitID:commit.ID]
                                                            autorelease];
        [self.navigationController pushViewController:commitViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionLabels && indexPath.row > 0) {
        GHAPILabelV3 *label = [self.issue.labels objectAtIndex:indexPath.row - 1];
        
        GHViewLabelViewController *labelViewController = [[[GHViewLabelViewController alloc] initWithRepository:self.repository  
                                                                                                          label:label]
                                                          autorelease];
        [self.navigationController pushViewController:labelViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
