//
//  GHPIssueViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssueViewController.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPUserTableViewCell.h"
#import "GHPMileStoneTableViewCell.h"
#import "GHPRepositoryViewController.h"
#import "GHPUserViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPCommitViewController.h"
#import "GHPNewCommentTableViewCell.h"
#import "GHPMilestoneViewController.h"
#import "ANNotificationQueue.h"
#import "GHViewCloudFileViewController.h"
#import "GHWebViewViewController.h"
#import "GHPLabelTableViewCell.h"
#import "GHPLabelViewController.h"

#define kUITableViewSectionInfo             0
#define kUITableViewSectionDetails          1
#define kUITableViewSectionLabels           2
#define kUITableViewSectionHistory          3
#define kUITableViewSectionCommits          4

#define kUITableViewNumberOfSections        5

#define kUIActionSheetTagAction             172634
#define kUIActionSheetTagLongPressedLink    172637

#define kUIAlertViewTagCommitMessage        12983

@implementation GHPIssueViewController

@synthesize repositoryString=_repositoryString, issueNumber=_issueNumber;
@synthesize repository=_repository, discussion=_discussion, history=_history;
@synthesize issue=_issue;
@synthesize selectedURL=_selectedURL;
@synthesize lastUserComment=_lastUserComment;

#pragma mark - setters and getters

- (NSString *)issueName {
    if (self.issue.isPullRequest) {
        return NSLocalizedString(@"Pull Request", @"");
    } else {
        return NSLocalizedString(@"Issue", @"");
    }
}

- (void)setIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repository {
    _repositoryString = [repository copy];
    _issueNumber = [issueNumber copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIIssueV3 issueOnRepository:_repositoryString withNumber:_issueNumber 
                  completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                      if (error) {
                          [self handleError:error];
                      } else {
                          [GHAPIRepositoryV3 repositoryNamed:_repositoryString 
                                       withCompletionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                                           if (error) {
                                               [self handleError:error];
                                           } else {
                                               self.issue = issue;
                                               self.repository = repository;
                                               self.isDownloadingEssentialData = NO;
                                           }
                                       }];
                      }
                  }];
}

- (void)setIssue:(GHAPIIssueV3 *)issue {
    if (issue != _issue) {
        _issue = issue;
        
        _bodyHeight = [GHPIssueInfoTableViewCell heightWithAttributedString:issue.attributedBody];
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Notifications

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    
    if ([issue isEqualToIssue:self.issue]) {
        self.issue = issue;
    }
}

#pragma mark - Initialization

- (id)initWithIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setIssueNumber:issueNumber onRepository:repository];
    }
    return self;
}

#pragma mark - instance methods

- (NSString *)descriptionForIssueEvent:(GHAPIIssueEventV3 *)event {
    NSString *description = nil;
    switch (event.type) {
        case GHAPIIssueEventTypeV3Closed:
            if (event.commitID) {
                description = [NSString stringWithFormat:NSLocalizedString(@"Closed this %@ in %@", @""), self.issueName, event.commitID];
            } else {
                description = [NSString stringWithFormat:NSLocalizedString(@"Closed this %@", @""), self.issueName];
            }
            break;
            
        case GHAPIIssueEventTypeV3Reopened:
            description = [NSString stringWithFormat:NSLocalizedString(@"Reopened this %@", @""), self.issueName];
            break;
            
        case GHAPIIssueEventTypeV3Subscribed:
            description = [NSString stringWithFormat:NSLocalizedString(@"Subscribed to this %@", @""), self.issueName];
            break;
            
        case GHAPIIssueEventTypeV3Merged:
            description = [NSString stringWithFormat:NSLocalizedString(@"Merged this %@ with %@", @""), self.issueName], event.commitID;
            break;
            
        case GHAPIIssueEventTypeV3Referenced:
            description = [NSString stringWithFormat:NSLocalizedString(@"This %@ was referenced in %@", @""), self.issueName, event.commitID];
            break;
            
        case GHAPIIssueEventTypeV3Mentioned:
            description = [NSString stringWithFormat:NSLocalizedString(@"Was mentioned in a body", @"")];
            break;
            
        case GHAPIIssueEventTypeV3Assigned:
            description = [NSString stringWithFormat:NSLocalizedString(@"Was assigned to this %@", @""), self.issueName];
            break;
            
        default:
            break;
    }
    
    return description;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionCommits || section == kUITableViewSectionHistory || section == kUITableViewSectionLabels;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionCommits) {
        return self.discussion == nil;
    } else if (section == kUITableViewSectionHistory) {
        return self.history == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionCommits) {
        cell.textLabel.text = NSLocalizedString(@"View attatched Commits", @"");
    } else if (section == kUITableViewSectionHistory) {
        cell.textLabel.text = NSLocalizedString(@"History", @"");
    } else if (section == kUITableViewSectionLabels) {
        cell.textLabel.text = NSLocalizedString(@"Labels", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionCommits) {
        [GHPullRequest pullRequestDiscussionOnRepository:self.repositoryString 
                                                  number:self.issueNumber 
                                       completionHandler:^(GHPullRequestDiscussion *discussion, NSError *error) {
                                           if (error) {
                                               [self handleError:error];
                                               [tableView cancelDownloadInSection:section];
                                           } else {
                                               self.discussion = discussion;
                                               [tableView expandSection:section animated:YES];
                                           }
                                       }];
    } else if (section == kUITableViewSectionHistory) {
        [GHAPIIssueV3 historyForIssueWithID:self.issueNumber onRepository:self.repositoryString 
                          completionHandler:^(NSMutableArray *history, NSError *error) {
                              if (!error) {
                                  self.history = history;
                                  [self cacheHeightsForHistroy];
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
    if (!self.issue) {
        return 0;
    }
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionInfo) {
        return 2;
    } else if (section == kUITableViewSectionDetails) {
        int counter = 1;    // repository
        if (self.issue.hasAssignee) {
            counter++;
        }
        if (self.issue.hasMilestone) {
            counter++;
        }
        return counter;
    } else if (section == kUITableViewSectionCommits) {
        return self.issue.isPullRequest ? [self.discussion.commits count] + 1 : 0;
    } else if (section == kUITableViewSectionHistory) {
        return self.history.count + 2;
    } else if (section == kUITableViewSectionLabels) {
        if (self.issue.labels.count == 0) {
            return 0;
        }
        return self.issue.labels.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            GHPInfoTableViewCell *cell = self.infoCell;
                        
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), self.issue.user.login, self.issue.createdAt.prettyTimeIntervalSinceNow];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), self.issue.number, self.issue.title];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.issue.user.avatarURL];
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"GHPIssueInfoTableViewCell";
            GHPIssueInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPIssueInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                              reuseIdentifier:CellIdentifier];
            }
            
            [cell.actionButton removeFromSuperview];
            
            cell.textLabel.text = nil;
            cell.imageView.image = nil;
            cell.buttonDelegate = self;
            cell.attributedTextView.attributedString = self.issue.attributedBody;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionDetails) {
        if (indexPath.row == 0) {
            // repository
            NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
            GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            GHAPIRepositoryV3 *repository = self.repository;
            
            cell.textLabel.text = repository.fullRepositoryName;
            cell.detailTextLabel.text = repository.description;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            return cell; 
        } else if (indexPath.row == 1) {
            if (self.issue.hasAssignee) {
                // this is the Assignee
                static NSString *CellIdentifier = @"GHPUserTableViewCell";
                
                GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                GHAPIUserV3 *user = self.issue.assignee;
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Assigned to %@", @""), user.login];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            } else if (self.issue.hasMilestone) {
                // Milestone
                static NSString *CellIdentifier = @"GHPMileStoneTableViewCell";
                
                GHPMileStoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPMileStoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone %@", @""), self.issue.milestone.title];
                
                GHAPIMilestoneV3 *milestone = self.issue.milestone;
                cell.progressView.progress = milestone.progress;
                
                if (milestone.dueInTime) {
                    [cell.progressView setTintColor:[UIColor greenColor] ];
                } else {
                    [cell.progressView setTintColor:[UIColor redColor] ];
                }
                
                return cell;
            }
        } else if (indexPath.row == 2) {
            // Milestone
            static NSString *CellIdentifier = @"GHPMileStoneTableViewCell";
            
            GHPMileStoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPMileStoneTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIMilestoneV3 *milestone = self.issue.milestone;
            
            cell.progressView.progress = milestone.progress;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone %@", @""), milestone.title];
            cell.detailTextLabel.text = milestone.dueFormattedString;
            
            if (milestone.dueInTime) {
                [cell.progressView setTintColor:[UIColor greenColor] ];
            } else {
                [cell.progressView setTintColor:[UIColor redColor] ];
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionCommits) {
        NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
        
        GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:commit.user.gravatarID];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", commit.commiter.name, commit.ID];
        cell.detailTextLabel.text = commit.message;
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionHistory) {
        if (indexPath.row == [self.history count] + 1) {
            // this is the new comment cell
            NSString *CellIdentifier = @"GHPNewCommentTableViewCell";
            
            GHPNewCommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL ];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
            cell.delegate = self;
            if (self.lastUserComment) {
                cell.textView.text = self.lastUserComment;
                self.lastUserComment = nil;
            }
            
            return cell;
        } else {
            NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
            
            if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
                static NSString *CellIdentifier = @"GHPIssueCommentTableViewCell";
                GHPAttributedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (!cell) {
                    cell = [[GHPAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];

                
                // display a comment
                GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
                
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), comment.user.login, comment.updatedAt.prettyTimeIntervalSinceNow];
                cell.buttonDelegate = self;
                cell.attributedTextView.attributedString = comment.attributedBody;
                
                return cell;
            } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
                static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
                GHPImageDetailTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (!cell) {
                    cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:event.actor.avatarURL];
                
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), event.actor.login, event.createdAt.prettyTimeIntervalSinceNow];
                cell.detailTextLabel.text = [self descriptionForIssueEvent:event];
                
                return cell;
            }
        }
    } else if (indexPath.section == kUITableViewSectionLabels) {
        static NSString *CellIdentifier = @"GHLabelTableViewCell";
        
        GHPLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHPLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPILabelV3 *label = [self.issue.labels objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = label.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *content = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), self.issue.number, self.issue.title];
            return [GHPInfoTableViewCell heightWithContent:content];
        } else if (indexPath.row == 1) {
            return _bodyHeight;
        }
    } else if (indexPath.section == kUITableViewSectionDetails) {
        if (indexPath.row == 0) {
            return [GHPRepositoryTableViewCell heightWithContent:self.repository.description];
        } else if (indexPath.row == 1) {
            if (self.issue.hasAssignee) {
                return GHPUserTableViewCellHeight;
            } else if (self.issue.hasMilestone) {
                return GHPMileStoneTableViewCellHeight;
            }
        } else if (indexPath.row == 2) {
            return GHPMileStoneTableViewCellHeight;
        }
    } else if (indexPath.section == kUITableViewSectionCommits && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row - 1];
        
        return [GHPImageDetailTableViewCell heightWithContent:commit.message];
    } else if (indexPath.section == kUITableViewSectionHistory && indexPath.row > 0) {
        if (indexPath.row == [self.history count] + 1) {
            return GHPNewCommentTableViewCellHeight;
        } else {
            return [self cachedHeightForRowAtIndexPath:indexPath];
        }
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionDetails) {
        if (indexPath.row == 0) {
            // repository
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:self.repositoryString];
        } else if (indexPath.row == 1) {
            if (self.issue.hasAssignee) {
                viewController = [[GHPUserViewController alloc] initWithUsername:self.issue.assignee.login];
            } else if (self.issue.hasMilestone) {
                viewController = [[GHPMilestoneViewController alloc] initWithRepository:self.repositoryString milestoneNumber:self.issue.milestone.number];
            }
        } else if (indexPath.row == 2) {
            if (self.issue.hasMilestone) {
                viewController = [[GHPMilestoneViewController alloc] initWithRepository:self.repositoryString milestoneNumber:self.issue.milestone.number];
            }
        }
    } else if (indexPath.section == kUITableViewSectionCommits && indexPath.row > 0) {
        GHCommit *commit = [self.discussion.commits objectAtIndex:indexPath.row-1];
        
        viewController = [[GHPCommitViewController alloc] initWithRepository:self.repositoryString 
                                                                     commitID:commit.ID];
    } else if (indexPath.section == kUITableViewSectionHistory && indexPath.row > 0 && indexPath.row < [self.history count]+1) {
        
        NSObject *object = [self.history objectAtIndex:indexPath.row - 1];
        
        if ([object isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)object;
            viewController = [[GHPUserViewController alloc] initWithUsername:comment.user.login];
        } else if ([object isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)object;
            
            switch (event.type) {
                case GHAPIIssueEventTypeV3Closed:
                    if (event.commitID) {
                        viewController = [[GHPCommitViewController alloc] initWithRepository:self.repositoryString commitID:event.commitID];
                    } else {
                        viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
                    }
                    break;
                    
                case GHAPIIssueEventTypeV3Reopened:
                    viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Subscribed:
                    viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Merged:
                    viewController = [[GHPCommitViewController alloc] initWithRepository:self.repositoryString commitID:event.commitID];
                    break;
                    
                case GHAPIIssueEventTypeV3Referenced:
                    viewController = [[GHPCommitViewController alloc] initWithRepository:self.repositoryString commitID:event.commitID];
                    break;
                    
                case GHAPIIssueEventTypeV3Mentioned:
                    viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                case GHAPIIssueEventTypeV3Assigned:
                    viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
                    break;
                    
                default:
                    break;
            }
        }
    } else if (indexPath.section == kUITableViewSectionLabels) {
        GHAPILabelV3 *label = [self.issue.labels objectAtIndex:indexPath.row - 1];
        viewController = [[GHPLabelViewController alloc] initWithRepository:self.repositoryString label:label];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Height caching

- (void)cacheHeightsForHistroy {
    [self.history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = UITableViewAutomaticDimension;
        
        if ([obj isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)obj;
            
            height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody];
        } else if ([obj isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)obj;
            
            height = [GHPImageDetailTableViewCell heightWithContent:[self descriptionForIssueEvent:event]];
        }
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionHistory]];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagCommitMessage && buttonIndex == 1) {
        // Merge clicked
        if (buttonIndex == 1) {
            NSString *commitMessage = [alertView textFieldAtIndex:0].text;
            [GHAPIPullRequestV3 mergPullRequestOnRepository:self.repositoryString withNumber:self.issueNumber commitMessage:commitMessage 
                                          completionHandler:^(GHAPIPullRequestMergeStateV3 *state, NSError *error) {
                                              self.actionButtonActive = NO;
                                              if (error) {
                                                  [self handleError:error];
                                              } else {
                                                  if ([state.merged boolValue]) {
                                                      // success
                                                      self.issue.state = kGHAPIIssueStateV3Closed;
                                                      [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully merged", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Pull Request %@", @""), self.issueNumber]];
                                                  } else {
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                                                      message:state.message 
                                                                                                     delegate:nil 
                                                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                            otherButtonTitles:nil];
                                                      [alert show];
                                                  }
                                              }
                                          }];
        } else {
            self.actionButtonActive = NO;
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagAction) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {
        }
        
        if ([title isEqualToString:NSLocalizedString(@"Merge", @"")]) {
            self.actionButtonActive = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Merge this Pull Request", @"") 
                                                            message:NSLocalizedString(@"Please input a Commit Message", @"") 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                  otherButtonTitles:NSLocalizedString(@"Merge", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewTagCommitMessage;
            [alert show];
        } else if ([title isEqualToString:NSLocalizedString(@"Reopen", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIIssueV3 reopenIssueOnRepository:self.repositoryString withNumber:self.issueNumber 
                                completionHandler:^(NSError *error) {
                                    self.actionButtonActive = NO;
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        self.issue.state = kGHAPIIssueStateV3Open;
                                        
                                        [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Reopened this %@", @""), self.issueName]];
                                    }
                                }];
        } else if ([title isEqualToString:NSLocalizedString(@"Close", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIIssueV3 closeIssueOnRepository:self.repositoryString withNumber:self.issueNumber 
                               completionHandler:^(NSError *error) {
                                   self.actionButtonActive = NO;
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       self.issue.state = kGHAPIIssueStateV3Closed;
                                       
                                       [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Closed this %@", @""), self.issueName]];
                                   }
                               }];
        } else if ([title isEqualToString:NSLocalizedString(@"Edit", @"")]) {
            GHUpdateIssueViewController *viewController = [[GHUpdateIssueViewController alloc] initWithIssue:self.issue];
            viewController.delegate = self;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:nil];
        }
    } else if (actionSheet.tag == kUIActionSheetTagLongPressedLink) {
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

#pragma mark - ActionMenu

- (void)downloadDataToDisplayActionButton {
    [GHAPIRepositoryV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
     collaboratorOnRepository:self.repositoryString 
            completionHandler:^(BOOL state, NSError *error) {
                if (error) {
                    [self failedToDownloadDataToDisplayActionButtonWithError:error];
                } else {
                    _hasCollaboratorData = YES;
                    _isCollaborator = state || [self.repositoryString hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
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
        
        if (issue.isOpen) {
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
    
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagAction;
    
    if (currentButtonIndex == 0) {
        return nil;
    }
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    return !_hasCollaboratorData;
}

#pragma mark - GHCreateIssueTableViewControllerDelegate

- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHAPIIssueV3 *)issue {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Updated Issue", @"") message:issue.title];
    self.issue = issue;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GHPIssueInfoTableViewCellDelegate

- (void)issueInfoTableViewCell:(GHPIssueInfoTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    UIViewController *viewController = [[GHWebViewViewController alloc] initWithURL:button.url ];
    viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

- (void)issueInfoTableViewCell:(GHPIssueInfoTableViewCell *)cell longPressRecognizedForButton:(DTLinkButton *)button {
    self.selectedURL = button.url;
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    sheet.title = button.url.absoluteString;
    [sheet addButtonWithTitle:NSLocalizedString(@"View in Safari", @"")];
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagLongPressedLink;
    
    [sheet showFromRect:[button convertRect:button.bounds toView:self.view] inView:self.view animated:YES];
}

#pragma mark - GHPNewCommentTableViewCellDelegate

- (void)newCommentTableViewCell:(GHPNewCommentTableViewCell *)cell didEnterText:(NSString *)text {
    UITextView *textView = cell.textView;
    [textView resignFirstResponder];
    
    [GHAPIIssueV3 postComment:textView.text 
         forIssueOnRepository:self.repositoryString 
                   withNumber:self.issueNumber 
            completionHandler:^(GHAPIIssueCommentV3 *comment, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    [self.history addObject:comment];
                    CGFloat height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody];
                    [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:self.history.count inSection:kUITableViewSectionHistory]];
                    self.issue.comments = [NSNumber numberWithInt:[self.issue.comments intValue] + 1];
                    
                    [self.tableView beginUpdates];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count]+1 inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.history count] inSection:kUITableViewSectionHistory]] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [self.tableView endUpdates];
                    
                    textView.text = nil;
                }
            }];
}

#pragma mark - GHPAttributedTableViewCellDelegate

- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    UIViewController *viewController = [[GHWebViewViewController alloc] initWithURL:button.url ];
    viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repositoryString forKey:@"repositoryString"];
    [encoder encodeObject:_issueNumber forKey:@"issueNumber"];
    [encoder encodeObject:_issue forKey:@"issue"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_discussion forKey:@"discussion"];
    [encoder encodeObject:_history forKey:@"history"];
    [encoder encodeFloat:_bodyHeight forKey:@"bodyHeight"];
    if (self.isViewLoaded) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.history.count+1 inSection:kUITableViewSectionHistory];
        GHPNewCommentTableViewCell *cell = nil;
        @try {
            cell = (GHPNewCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
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
        _repositoryString = [decoder decodeObjectForKey:@"repositoryString"];
        _issueNumber = [decoder decodeObjectForKey:@"issueNumber"];
        _issue = [decoder decodeObjectForKey:@"issue"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _discussion = [decoder decodeObjectForKey:@"discussion"];
        _history = [decoder decodeObjectForKey:@"history"];
        _bodyHeight = [decoder decodeFloatForKey:@"bodyHeight"];
        _lastUserComment = [decoder decodeObjectForKey:@"lastUserComment"];
    }
    return self;
}

@end
