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

#define kUITableViewSectionInfo             0
#define kUITableViewSectionDetails          1
#define kUITableViewSectionCommits          2
#define kUITableViewSectionHistory          3

#define kUITableViewNumberOfSections        4

#define kUIActionSheetTagAction             172634
#define kUIActionSheetTagLongPressedLink    172637

#define kUIAlertViewTagCommitMessage        12983
#define kUIAlertViewTagInputAssignee        12986

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
                                               _bodyHeight = [GHPIssueInfoTableViewCell heightWithAttributedString:issue.attributedBody 
                                                                                              inAttributedTextView:nil];
                                               self.repository = repository;
                                               self.isDownloadingEssentialData = NO;
                                               if (self.isViewLoaded) {
                                                   [self.tableView reloadData];
                                               }
                                           }
                                       }];
                      }
                  }];
}

#pragma mark - Initialization

- (id)initWithIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setIssueNumber:issueNumber onRepository:repository];
    }
    return self;
}

#pragma mark - Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    return section == kUITableViewSectionCommits || section == kUITableViewSectionHistory;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionCommits) {
        return self.discussion == nil;
    }else if (section == kUITableViewSectionHistory) {
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
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Height caching

- (void)cacheHeightsForHistroy {
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    [self.history enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = UITableViewAutomaticDimension;
        
        if ([obj isKindOfClass:[GHAPIIssueCommentV3 class] ]) {
            // display a comment
            GHAPIIssueCommentV3 *comment = (GHAPIIssueCommentV3 *)obj;
            
            height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody 
                                                         inAttributedTextView:textView];
        } else if ([obj isKindOfClass:[GHAPIIssueEventV3 class] ]) {
            GHAPIIssueEventV3 *event = (GHAPIIssueEventV3 *)obj;
            
            height = [GHPImageDetailTableViewCell heightWithContent:[self descriptionForIssueEvent:event]];
        }
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionHistory]];
    }];
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
        
        [self setActionButtonActive:YES];
        
        if ([title isEqualToString:NSLocalizedString(@"Merge this Pull Request", @"")]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Merge this Pull Request", @"") 
                                                             message:NSLocalizedString(@"Please input a Commit Message", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Merge", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewTagCommitMessage;
            [alert show];
        } else if ([title isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"Reopen this %@", @""), self.issueName]]) {
            [GHAPIIssueV3 reopenIssueOnRepository:self.repositoryString withNumber:self.issueNumber 
                                completionHandler:^(NSError *error) {
                                    [self setActionButtonActive:NO];
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        self.issue.state = kGHAPIIssueStateV3Open;
                                    }
                                }];
        } else if ([title isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"Close this %@", @""), self.issueName]]) {
            [GHAPIIssueV3 closeIssueOnRepository:self.repositoryString withNumber:self.issueNumber 
                               completionHandler:^(NSError *error) {
                                   [self setActionButtonActive:NO];
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       self.issue.state = kGHAPIIssueStateV3Closed;
                                   }
                               }];
        } else if ([title isEqualToString:NSLocalizedString(@"Update Assignee", @"")]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Assignee", @"") 
                                                             message:NSLocalizedString(@"", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Submit", @""), nil];
            alert.tag = kUIAlertViewTagInputAssignee;
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        } else {
            [self setActionButtonActive:NO];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagCommitMessage && buttonIndex == 1) {
        // Merge clicked
        
        NSString *commitMessage = [alertView textFieldAtIndex:0].text;
        [GHAPIPullRequestV3 mergPullRequestOnRepository:self.repositoryString withNumber:self.issueNumber commitMessage:commitMessage 
                                      completionHandler:^(GHAPIPullRequestMergeStateV3 *state, NSError *error) {
                                          [self setActionButtonActive:NO];
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

    } else if (alertView.tag == kUIAlertViewTagInputAssignee) {
        if (buttonIndex > 0) {
            // submit clicked
            NSString *assignee = [alertView textFieldAtIndex:0].text;
            [GHAPIIssueV3 updateIssueOnRepository:self.repositoryString withNumber:self.issueNumber 
                                            title:nil body:nil 
                                         assignee:assignee 
                                            state:nil milestone:nil labels:nil 
                                completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                                    [self setActionButtonActive:NO];
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully assigned", @"") 
                                                                                                         message:issue.assignee.login];
                                        self.issue = issue;
                                        if (self.isViewLoaded) {
                                            [self.tableView reloadDataAndResetExpansionStates:NO];
                                        }
                                    }
                                }];
        } else {
            // cancel clicked
            [self setActionButtonActive:NO];
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
                    
                    [self didDownloadDataToDisplayActionButton];
                }
            }];
}

- (UIActionSheet *)actionButtonActionSheet {
    if (!_isCollaborator && ![[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login isEqualToString:self.issue.user.login]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"You are not allowed to administrate this %@", @""), self.issueName] 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                               otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    if ([self.issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Close this %@", @""), self.issueName]];
    } else {
        [sheet addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Reopen this %@", @""), self.issueName]];
    }
    
    if (_isCollaborator) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Update Assignee", @"")];
    }
    
    if (self.issue.isPullRequest && _isCollaborator && [self.issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Merge this Pull Request", @"")];
    }
    
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagAction;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)canDisplayActionButtonActionSheet {
    return _hasCollaboratorData;
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
                    CGFloat height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody 
                                                                       inAttributedTextView:nil];
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
