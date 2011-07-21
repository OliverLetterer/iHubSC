//
//  GHViewIssueTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueViewController.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "GHIssueTitleTableViewCell.h"
#import "GHIssueDescriptionTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHIssueCommentTableViewCell.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHNewCommentTableViewCell.h"
#import "GHUserViewController.h"
#import "GHRepositoryViewController.h"
#import "GHAPIMilestoneV3TableViewCell.h"
#import "GHViewCommitViewController.h"
#import "GHMilestoneViewController.h"
#import "GHLabelTableViewCell.h"
#import "GHViewLabelViewController.h"
#import "ANNotificationQueue.h"
#import "GHWebViewViewController.h"
#import "GHIssueCommentTableViewCell.h"

#define kUITableViewSectionData             0
#define kUITableViewSectionAssignee         1
#define kUITableViewSectionMilestone        2
#define kUITableViewSectionCommits          3
#define kUITableViewSectionLabels           4
#define kUITableViewSectionHistory          5
#define kUITableViewSectionAdministration   6

#define kUITableViesNumberOfSections        7

#define kUIAlertViewTagInputAssignee        12316
#define kUIAlertViewTagMergePullRequest     12317

#define kUIActionSheetTagLongPressedLink    97312

@implementation GHIssueViewController

@synthesize issue=_issue;
@synthesize repository=_repository, number=_number;
@synthesize history=_history, discussion=_discussion;
@synthesize textView=_textView, textViewToolBar=_textViewToolBar, attributedTextView=_attributedTextView;
@synthesize selectedURL=_selectedURL;

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
        [self downloadIssueData];
    }
    return self;
}

#pragma mark - instance methods

- (void)downloadIssueData {
    self.isDownloadingEssentialData = YES;
    [GHAPIIssueV3 issueOnRepository:self.repository withNumber:self.number completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
        self.isDownloadingEssentialData = NO;
        if (error) {
            [self handleError:error];
        } else {
            self.issue = issue;
            [self cacheHeight:[GHIssueTitleTableViewCell heightWithAttributedString:self.issue.attributedBody 
                                                               inAttributedTextView:self.attributedTextView] 
            forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionData] ];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), self.issueName, self.number];
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
    [_attributedTextView release];
    [_selectedURL release];
    
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
                 [self cacheHeightsForHistroy];
                 
                 self.issue.comments = [NSNumber numberWithInt:[self.issue.comments intValue] + 1];
                 
                 [self.tableView beginUpdates];
                 
                 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count]+1 inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count] inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 
                 [self.tableView endUpdates];
                 
                 self.textView.text = nil;
             }
         }];
}

#pragma mark - View lifecycle

- (void)loadView {
    self.attributedTextView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
    [super loadView];
}

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
    self.attributedTextView = nil;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section != kUITableViewSectionData && section != kUITableViewSectionMilestone && section != kUITableViewSectionAssignee;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionHistory) {
        return self.history == nil;
    } else if (section == kUITableViewSectionCommits) {
        return self.discussion == nil;
    } else if (section == kUITableViewSectionAdministration) {
        return !_hasCollaboratorData;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
                                  [self cacheHeightsForHistroy];
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
    } else if (section == kUITableViewSectionAdministration) {
        [GHAPIRepositoryV3 isUser:[GHAuthenticationManager sharedInstance].username 
         collaboratorOnRepository:self.repository 
                completionHandler:^(BOOL state, NSError *error) {
                    if (error) {
                        [self handleError:error];
                        [tableView cancelDownloadInSection:section];
                    } else {
                        _hasCollaboratorData = YES;
                        _isCollaborator = state || [self.repository hasPrefix:[GHAuthenticationManager sharedInstance].username] || [self.issue.user.login isEqualToString:[GHAuthenticationManager sharedInstance].username];
                        [tableView expandSection:section animated:YES];
                    }
                }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger result = 0;
    
    if (!self.issue) {
        result = 0;
    } else {
        return kUITableViesNumberOfSections;
    }
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = 0;
    
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
        result = 1;
        if (_hasCollaboratorData) {
            if (_isCollaborator) {
                result++;
                result++;   // Update Assignee
            }
            if (self.issue.isPullRequest && _isCollaborator && [self.issue.state isEqualToString:kGHAPIIssueStateV3Open] && ![self.issue.user.login isEqualToString:[GHAuthenticationManager sharedInstance].username]) {
                result++;
            }
        }
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
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionData) {
        // the issue itself
        if (indexPath.row == 0) {
            // the title
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = self.issue.title;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", self.issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), self.issue.createdAt.prettyTimeIntervalSinceNow] ];
            ;
            cell.attributedTextView.attributedString = self.issue.attributedBody;
            cell.buttonDelegate = self;
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if (indexPath.row == 1) {
            // open/ close
            
            if ([self.issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Close this %@", @""), self.issueName];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Reopen this %@", @""), self.issueName];
            }
        } else if (indexPath.row == 2) {
            // Update Assignee
            cell.textLabel.text = NSLocalizedString(@"Update Assignee", @"");
        } else if (indexPath.row == 3) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Merge this %@", @""), self.issueName];
        }
        return cell;
    } else if (indexPath.section == kUITableViewSectionHistory) {
        if (indexPath.row == [self.history count] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHSettingsHelper avatarURL]];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHSettingsHelper username]];
            
            self.textView = cell.textView;
            cell.textView.inputAccessoryView = self.textViewToolBar;
            self.textView.scrollsToTop = NO;
            
            return cell;
        }
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            static NSString *CellIdentifier = @"GHIssueCommentTableViewCell";
            GHIssueCommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[[GHIssueCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;

            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.buttonDelegate = self;
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on this %@", @""), comment.user.login, self.issueName];
            cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), comment.updatedAt.prettyTimeIntervalSinceNow];
            cell.attributedTextView.attributedString = comment.attributedBody;
            
            return cell;
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:event.actor.avatarURL];
            
            cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), event.createdAt.prettyTimeIntervalSinceNow];
            
            cell.descriptionLabel.text = nil;
            cell.textLabel.text = nil;
            
            switch (event.type) {
                case GHAPIIssueEventTypeV3Closed:
                    ;
                    NSString *description = nil;
                    if (event.commitID) {
                        description = [NSString stringWithFormat:NSLocalizedString(@"%@ closed this %@ in", @""), event.actor.login, self.issueName];
                    } else {
                        description = [NSString stringWithFormat:NSLocalizedString(@"%@ closed this %@", @""), event.actor.login, self.issueName];
                    }
                    cell.textLabel.text = description;
                    cell.descriptionLabel.text = event.commitID;
                    break;
                    
                case GHAPIIssueEventTypeV3Reopened:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ reopened this %@", @""), event.actor.login, self.issueName];
                    break;
                    
                case GHAPIIssueEventTypeV3Subscribed:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ subscribed to this %@", @""), event.actor.login, self.issueName];
                    break;
                    
                case GHAPIIssueEventTypeV3Merged:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ merged this %@ with", @""), event.actor.login, self.issueName];
                    cell.descriptionLabel.text = event.commitID;
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Referenced:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"This %@ was referenced in", @""), self.issueName];
                    cell.descriptionLabel.text = event.commitID;
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Mentioned:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ was mentioned in a body", @""), event.actor.login];
                    
                    break;
                    
                case GHAPIIssueEventTypeV3Assigned:
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ was assigned to this %@", @""), event.actor.login, self.issueName];
                    
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
        
        cell.textLabel.text = commit.ID;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0f;
    
    if (indexPath.section == kUITableViewSectionData) {
        if (indexPath.row == 0) {
            // the issues title
            return [self cachedHeightForRowAtIndexPath:indexPath];
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
        
        return [self cachedHeightForRowAtIndexPath:indexPath];
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
            if ([self.issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
                [GHAPIIssueV3 closeIssueOnRepository:self.repository 
                                          withNumber:self.number
                                   completionHandler:^(NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           self.issue.state = kGHAPIIssueStateV3Closed;
                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionAdministration]
                                                         withRowAnimation:UITableViewRowAnimationFade];
                                           
                                           [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Closed this %@", @""), self.issueName]];
                                       }
                                   }];
            } else {
                [GHAPIIssueV3 reopenIssueOnRepository:self.repository withNumber:self.number 
                                    completionHandler:^(NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            self.issue.state = kGHAPIIssueStateV3Open;
                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionAdministration]
                                                          withRowAnimation:UITableViewRowAnimationFade];
                                            
                                            [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Reoped this %@", @""), self.issueName] ];
                                        }
                                    }];
            }
        } else if (indexPath.row == 2) {
            // Update assignee
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Assignee", @"") 
                                                             message:NSLocalizedString(@"", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Submit", @""), nil]
                                  autorelease];
            alert.tag = kUIAlertViewTagInputAssignee;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        } else if (indexPath.row == 3) {
            // Pull Request
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Merge message", @"") 
                                                             message:nil 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Merge", @""), nil]
                                  autorelease];
            alert.tag = kUIAlertViewTagMergePullRequest;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
    } else if (indexPath.section == kUITableViewSectionData) {
        if (indexPath.row == 0) {
            GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.issue.user.login] autorelease];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if (indexPath.row == 1) {
            GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:self.repository] autorelease];
            [self.navigationController pushViewController:repoViewController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionAssignee && indexPath.row == 0) {
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.issue.assignee.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionMilestone && indexPath.row == 0) {
        GHAPIMilestoneV3 *milestone = self.issue.milestone;
        GHMilestoneViewController *milestoneViewController = [[[GHMilestoneViewController alloc] initWithRepository:self.repository milestoneNumber:milestone.number] autorelease];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagInputAssignee) {
        if (buttonIndex > 0) {
            // submit clicked
            NSString *assignee = [alertView textFieldAtIndex:0].text;
            [GHAPIIssueV3 updateIssueOnRepository:self.repository 
                                       withNumber:self.issue.number 
                                            title:nil body:nil 
                                         assignee:assignee 
                                            state:nil milestone:nil labels:nil 
                                completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        self.issue = issue;
                                        [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully assigned", @"") 
                                                                                                         message:issue.assignee.login];
                                        if (self.isViewLoaded) {
                                            [self.tableView reloadData];
                                        }
                                    }
                                }];
        }
    } else if (alertView.tag == kUIAlertViewTagMergePullRequest) {
        if (buttonIndex == 1) {
            [GHAPIPullRequestV3 mergPullRequestOnRepository:self.repository withNumber:self.number 
                                              commitMessage:[alertView textFieldAtIndex:0].text 
                                          completionHandler:^(GHAPIPullRequestMergeStateV3 *state, NSError *error) {
                                              if (error) {
                                                  [self handleError:error];
                                              } else {
                                                  if (state.merged.boolValue) {
                                                      [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Merge successful", @"") message:state.message];
                                                      self.issue.state = kGHAPIIssueStateV3Closed;
                                                  } else {
                                                      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Merge failed", @"") 
                                                                                                       message:state.message 
                                                                                                      delegate:nil 
                                                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                             otherButtonTitles:nil]
                                                                            autorelease];
                                                      [alert show];
                                                  }
                                                  
                                                  [self.tableView reloadDataAndResetExpansionStates:NO];
                                              }
                                          }];
        }
    }
}

#pragma mark - Height caching

- (void)cacheHeightsForHistroy {
    [self.history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionHistory];
        
        CGFloat height = 71.0f;
        
        if ([obj isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = obj;
            
            CGSize size = [comment.body sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                   constrainedToSize:CGSizeMake(222.0, MAXFLOAT) 
                                       lineBreakMode:UILineBreakModeWordWrap];
            
            height = size.height + 50.0;
            
            if (height < 71.0) {
                height = 71.0;
            }
        }
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagLongPressedLink) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {
        }
        
        if ([title isEqualToString:NSLocalizedString(@"View in Safari", @"")]) {
            [[UIApplication sharedApplication] openURL:self.selectedURL];
        }
    }
}

#pragma mark - GHIssueTitleTableViewCellDelegate

- (void)issueInfoTableViewCell:(GHIssueTitleTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    GHWebViewViewController *viewController = [[[GHWebViewViewController alloc] initWithURL:button.url ] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)issueInfoTableViewCell:(GHIssueTitleTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button {
    self.selectedURL = button.url;
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    sheet.title = button.url.absoluteString;
    [sheet addButtonWithTitle:NSLocalizedString(@"View in Safari", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = 1;
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagLongPressedLink;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:self.tabBarController.view];
}

#pragma mark - GHIssueCommentTableViewCellDelegate

- (void)commentTableViewCell:(GHIssueCommentTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    GHWebViewViewController *viewController = [[[GHWebViewViewController alloc] initWithURL:button.url ] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)commentTableViewCell:(GHIssueCommentTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button {
    self.selectedURL = button.url;
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    sheet.title = button.url.absoluteString;
    [sheet addButtonWithTitle:NSLocalizedString(@"View in Safari", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = 1;
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagLongPressedLink;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:self.tabBarController.view];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_issue forKey:@"issue"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_history forKey:@"history"];
    [encoder encodeObject:_discussion forKey:@"discussion"];
    [encoder encodeObject:_textView forKey:@"textView"];
    [encoder encodeObject:_textViewToolBar forKey:@"textViewToolBar"];
    [encoder encodeObject:_attributedTextView forKey:@"attributedTextView"];
    [encoder encodeObject:_selectedURL forKey:@"selectedURL"];
    [encoder encodeBool:_hasCollaboratorData forKey:@"hasCollaboratorData"];
    [encoder encodeBool:_isCollaborator forKey:@"isCollaborator"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _issue = [[decoder decodeObjectForKey:@"issue"] retain];
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
        _number = [[decoder decodeObjectForKey:@"number"] retain];
        _history = [[decoder decodeObjectForKey:@"history"] retain];
        _discussion = [[decoder decodeObjectForKey:@"discussion"] retain];
        _textView = [[decoder decodeObjectForKey:@"textView"] retain];
        _textViewToolBar = [[decoder decodeObjectForKey:@"textViewToolBar"] retain];
        _attributedTextView = [[decoder decodeObjectForKey:@"attributedTextView"] retain];
        _selectedURL = [[decoder decodeObjectForKey:@"selectedURL"] retain];
        _hasCollaboratorData = [decoder decodeBoolForKey:@"hasCollaboratorData"];
        _isCollaborator = [decoder decodeBoolForKey:@"isCollaborator"];
    }
    return self;
}

@end
