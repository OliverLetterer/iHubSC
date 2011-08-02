//
//  GHViewIssueTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueViewController.h"
#import "GithubAPI.h"
#import "GHAttributedTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHDescriptionTableViewCell.h"
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

#define kUITableViewSectionData             0
#define kUITableViewSectionAssignee         1
#define kUITableViewSectionMilestone        2
#define kUITableViewSectionCommits          3
#define kUITableViewSectionLabels           4
#define kUITableViewSectionHistory          5

#define kUITableViesNumberOfSections        6

#define kUIAlertViewTagMergePullRequest     12317

@implementation GHIssueViewController

@synthesize issue=_issue;
@synthesize repository=_repository, number=_number;
@synthesize history=_history, discussion=_discussion;
@synthesize lastUserComment=_lastUserComment;

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
            [self cacheHeight:[GHAttributedTableViewCell heightWithAttributedString:self.issue.attributedBody 
                                                               inAttributedTextView:nil] 
            forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionData] ];
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), self.issueName, self.number];
            [self.tableView reloadData];
        }
    }];
}

- (NSString *)descriptionForEvent:(GHAPIIssueEventV3 *)event {
    NSString *description = nil;
    
    switch (event.type) {
        case GHAPIIssueEventTypeV3Closed:
            if (event.commitID) {
                description = [NSString stringWithFormat:NSLocalizedString(@"closed this %@ in", @""), self.issueName];
            } else {
                description = [NSString stringWithFormat:NSLocalizedString(@"closed this %@", @""), self.issueName];
            }
            break;
            
        case GHAPIIssueEventTypeV3Reopened:
            description = [NSString stringWithFormat:NSLocalizedString(@"reopened this %@", @""), self.issueName];
            break;
            
        case GHAPIIssueEventTypeV3Subscribed:
            description = [NSString stringWithFormat:NSLocalizedString(@"subscribed to this %@", @""), self.issueName];
            break;
            
        case GHAPIIssueEventTypeV3Merged:
            description = [NSString stringWithFormat:NSLocalizedString(@"merged this %@ with", @""), self.issueName];
            description = [NSString stringWithFormat:@"%@\n\n%@", description, event.commitID];
            break;
            
        case GHAPIIssueEventTypeV3Referenced:
            description = [NSString stringWithFormat:NSLocalizedString(@"This %@ was referenced in", @""), self.issueName];
            description = [NSString stringWithFormat:@"%@\n\n%@", description, event.commitID];
            break;
            
        case GHAPIIssueEventTypeV3Mentioned:
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ was mentioned in a body", @""), event.actor.login];
            break;
            
        case GHAPIIssueEventTypeV3Assigned:
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ was assigned to this %@", @""), event.actor.login, self.issueName];
            break;
            
        default:
            break;
    }
    return description;
}

#pragma mark - GHNewCommentTableViewCell

- (void)newCommentTableViewCell:(GHNewCommentTableViewCell *)cell didEnterText:(NSString *)text {
    UITextView *textView = cell.textView;
    [textView resignFirstResponder];
    
    [GHAPIIssueV3 postComment:textView.text 
      forIssueOnRepository:self.repository 
                withNumber:self.number 
         completionHandler:^(GHAPIIssueCommentV3 *comment, NSError *error) {
             if (error) {
                 [self handleError:error];
             } else {
                 NSMutableArray *tmpArray = [self.history mutableCopy];
                 [tmpArray addObject:comment];
                 self.history = tmpArray;
                 [self cacheHeightsForHistroy];
                 
                 self.issue.comments = [NSNumber numberWithInt:[self.issue.comments intValue] + 1];
                 
                 [self.tableView beginUpdates];
                 
                 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count]+1 inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count] inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                 
                 [self.tableView endUpdates];
                 
                 textView.text = nil;
             }
         }];
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
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (section == kUITableViewSectionHistory) {
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
            static NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHAttributedTableViewCell *cell = (GHAttributedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = self.issue.title;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", self.issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), self.issue.createdAt.prettyTimeIntervalSinceNow] ];
            ;
            cell.attributedTextView.attributedString = self.issue.attributedBody;
            cell.buttonDelegate = self;
            
            cell.attributedString = self.issue.attributedBody;
            cell.selectedAttributesString = self.issue.selectedAttributedBody;
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
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
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
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
                cell = [[GHAPIMilestoneV3TableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
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
    } else if (indexPath.section == kUITableViewSectionHistory) {
        if (indexPath.row == [self.history count] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
            cell.delegate = self;
            if (self.lastUserComment) {
                cell.textView.text = self.lastUserComment;
                self.lastUserComment = nil;
            }
            
            return cell;
        }
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            static NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHAttributedTableViewCell *cell = (GHAttributedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.buttonDelegate = self;
            cell.textLabel.text = comment.user.login;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), comment.updatedAt.prettyTimeIntervalSinceNow];
            cell.attributedTextView.attributedString = comment.attributedBody;
            
            cell.attributedString = comment.attributedBody;
            cell.selectedAttributesString = comment.selectedAttributedBody;
            
            return cell;
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:event.actor.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), event.createdAt.prettyTimeIntervalSinceNow];
            
            cell.descriptionLabel.text = [self descriptionForEvent:event];
            cell.textLabel.text = event.actor.login;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionCommits) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
            cell = [[GHLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
            return GHNewCommentTableViewCellHeight;
        }
        
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionCommits && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row - 1];
        
        return [GHDescriptionTableViewCell heightWithContent:commit.message];
    }
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionData) {
        if (indexPath.row == 0) {
            GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:self.issue.user.login];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if (indexPath.row == 1) {
            GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:self.repository];
            [self.navigationController pushViewController:repoViewController animated:YES];
        }
    } else if (indexPath.section == kUITableViewSectionAssignee && indexPath.row == 0) {
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:self.issue.assignee.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionMilestone && indexPath.row == 0) {
        GHAPIMilestoneV3 *milestone = self.issue.milestone;
        GHMilestoneViewController *milestoneViewController = [[GHMilestoneViewController alloc] initWithRepository:self.repository milestoneNumber:milestone.number];
        [self.navigationController pushViewController:milestoneViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionHistory && indexPath.row > 0 && indexPath.row < [self.history count]+1) {
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
            GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:comment.user.login];
            [self.navigationController pushViewController:userViewController animated:YES];
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            UIViewController *nextViewController = nil;
            
            switch (event.type) {
                case GHAPIIssueEventTypeV3Closed:
                    if (event.commitID) {
                        nextViewController = [[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID];
                    } else {
                        nextViewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
                    }
                    break;
                    
                case GHAPIIssueEventTypeV3Reopened:
                    nextViewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Subscribed:
                    nextViewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Merged:
                    nextViewController = [[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID];
                    break;
                    
                case GHAPIIssueEventTypeV3Referenced:
                    nextViewController = [[GHViewCommitViewController alloc] initWithRepository:self.repository commitID:event.commitID];
                    break;
                    
                case GHAPIIssueEventTypeV3Mentioned:
                    nextViewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Assigned:
                    nextViewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
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
        
        GHViewCommitViewController *commitViewController = [[GHViewCommitViewController alloc] initWithRepository:repo
                                                                                                          commitID:commit.ID];
        [self.navigationController pushViewController:commitViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionLabels && indexPath.row > 0) {
        GHAPILabelV3 *label = [self.issue.labels objectAtIndex:indexPath.row - 1];
        
        GHViewLabelViewController *labelViewController = [[GHViewLabelViewController alloc] initWithRepository:self.repository  
                                                                                                          label:label];
        [self.navigationController pushViewController:labelViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagMergePullRequest) {
        if (buttonIndex == 1) {
            [GHAPIPullRequestV3 mergPullRequestOnRepository:self.repository withNumber:self.number 
                                              commitMessage:[alertView textFieldAtIndex:0].text 
                                          completionHandler:^(GHAPIPullRequestMergeStateV3 *state, NSError *error) {
                                              self.actionButtonActive = NO;
                                              if (error) {
                                                  [self handleError:error];
                                              } else {
                                                  if (state.merged.boolValue) {
                                                      [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Merge successful", @"") message:state.message];
                                                      self.issue.state = kGHAPIIssueStateV3Closed;
                                                  } else {
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Merge failed", @"") 
                                                                                                       message:state.message 
                                                                                                      delegate:nil 
                                                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                             otherButtonTitles:nil];
                                                      [alert show];
                                                  }
                                                  
                                                  [self.tableView reloadDataAndResetExpansionStates:NO];
                                              }
                                          }];
        } else {
            self.actionButtonActive = NO;
        }
    }
}

#pragma mark - Height caching

- (void)cacheHeightsForHistroy {
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    [self.history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = 44.0f;
        
        if ([obj isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)obj;
            
            height = [GHAttributedTableViewCell heightWithAttributedString:comment.attributedBody 
                                                      inAttributedTextView:textView];
        } else if ([obj isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = obj;
            height = [GHDescriptionTableViewCell heightWithContent:[self descriptionForEvent:event] ];
        }
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionHistory]];
    }];
}

#pragma mark - GHIssueTitleTableViewCellDelegate

- (void)attributedTableViewCell:(GHAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    GHWebViewViewController *viewController = [[GHWebViewViewController alloc] initWithURL:button.url ];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_issue forKey:@"issue"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_history forKey:@"history"];
    [encoder encodeObject:_discussion forKey:@"discussion"];
    [encoder encodeBool:_hasCollaboratorData forKey:@"hasCollaboratorData"];
    [encoder encodeBool:_isCollaborator forKey:@"isCollaborator"];
    
    if (self.isViewLoaded) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.history.count+1 inSection:kUITableViewSectionHistory];
        GHNewCommentTableViewCell *cell = nil;
        @try {
            cell = (GHNewCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        }
        @catch (NSException *exception) { }
        NSString *text = cell.textView.text;
        
        if (text != nil) {
            [encoder encodeObject:text forKey:@"lastUserComment"];
        }
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _issue = [decoder decodeObjectForKey:@"issue"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _number = [decoder decodeObjectForKey:@"number"];
        _history = [decoder decodeObjectForKey:@"history"];
        _discussion = [decoder decodeObjectForKey:@"discussion"];
        _hasCollaboratorData = [decoder decodeBoolForKey:@"hasCollaboratorData"];
        _isCollaborator = [decoder decodeBoolForKey:@"isCollaborator"];
        _lastUserComment = [decoder decodeObjectForKey:@"lastUserComment"];
    }
    return self;
}

#pragma mark - GHCreateIssueTableViewControllerDelegate

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHAPIIssueV3 *)issue {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Updated Issue", @"") message:issue.title];
    self.issue = issue;
    [self cacheHeight:[GHAttributedTableViewCell heightWithAttributedString:self.issue.attributedBody 
                                                       inAttributedTextView:nil] 
    forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionData] ];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionButtonActionSheetTag) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Edit", @"")]) {
            GHUpdateIssueViewController *viewController = [[GHUpdateIssueViewController alloc] initWithIssue:self.issue];
            viewController.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:navController animated:YES completion:nil];
        } else if ([title isEqualToString:NSLocalizedString(@"Close", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIIssueV3 closeIssueOnRepository:self.repository 
                                      withNumber:self.number
                               completionHandler:^(NSError *error) {
                                   self.actionButtonActive = NO;
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       self.issue.state = kGHAPIIssueStateV3Closed;
                                       
                                       [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Closed this %@", @""), self.issueName]];
                                   }
                               }];
        } else if ([title isEqualToString:NSLocalizedString(@"Reopen", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIIssueV3 reopenIssueOnRepository:self.repository withNumber:self.number 
                                completionHandler:^(NSError *error) {
                                    self.actionButtonActive = NO;
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        self.issue.state = kGHAPIIssueStateV3Open;
                                        
                                        [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Reoped this %@", @""), self.issueName] ];
                                    }
                                }];
        } else if ([title isEqualToString:NSLocalizedString(@"Merge", @"")]) {
            self.actionButtonActive = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input merge message", @"") 
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                  otherButtonTitles:NSLocalizedString(@"Merge", @""), nil];
            alert.tag = kUIAlertViewTagMergePullRequest;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    [GHAPIRepositoryV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
     collaboratorOnRepository:self.repository 
            completionHandler:^(BOOL state, NSError *error) {
                if (error) {
                    [self failedToDownloadDataToDisplayActionButtonWithError:error];
                } else {
                    _hasCollaboratorData = YES;
                    _isCollaborator = state || [self.repository hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
                    _isCreatorOfIssue = [self.issue.user.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
                    
                    [self didDownloadDataToDisplayActionButton];
                }
            }];
}

- (UIActionSheet *)actionButtonActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), self.issueName, self.issue.number];
    NSUInteger currentButtonIndex = 0;
    
    if (_isCreatorOfIssue || _isCollaborator) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Edit", @"")];
        currentButtonIndex++;
        
        if ([self.issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Close", @"")];
            sheet.destructiveButtonIndex = currentButtonIndex;
            currentButtonIndex++;
        } else {
            [sheet addButtonWithTitle:NSLocalizedString(@"Reopen", @"")];
            currentButtonIndex++;
        }
        
        if (self.issue.isPullRequest) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Merge", @"")];
            sheet.destructiveButtonIndex = currentButtonIndex;
            currentButtonIndex++;
        }
    }
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = currentButtonIndex;
    currentButtonIndex++;
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.delegate = self;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    return !_hasCollaboratorData;
}

@end
