//
//  GHViewMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHMilestoneViewController.h"
#import "GHAPIMilestoneV3TableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHIssueViewController.h"

#define kUITableViewControllerSectionInfo               0
#define kUITableViewControllerSectionInfoOpenIssues     1
#define kUITableViewControllerSectionInfoClosedIssues   2

#define kUITableViewControllerNumberOfSections          3

@implementation GHMilestoneViewController

@synthesize milestone=_milestone, repository=_repository, milestoneNumber=_milestoneNumber;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.milestoneNumber = milestoneNumber;
        self.repository = repository;
        [self downloadMilestoneData];
    }
    return self;
}

- (void)downloadMilestoneData {
    self.isDownloadingEssentialData = YES;
    [GHAPIMilestoneV3 milestoneOnRepository:self.repository number:self.milestoneNumber 
                          completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                              self.isDownloadingEssentialData = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.milestone = milestone;
                                  self.title = self.milestone.title;
                                  if ([self isViewLoaded]) {
                                      [self.tableView reloadData];
                                  }
                              }
                          }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_milestone release];
    [_repository release];
    [_milestoneNumber release];
    [_openIssues release];
    [_closedIssues release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewControllerSectionInfoOpenIssues || section == kUITableViewControllerSectionInfoClosedIssues;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues == nil;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues (%@)", @""), self.milestone.openIssues];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Closed Issues (%@)", @""), self.milestone.closedIssues];
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil 
                                   state:kGHAPIIssueStateV3Open page:page 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.openIssues addObjectsFromArray:array];
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil
                                   state:kGHAPIIssueStateV3Closed page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.closedIssues addObjectsFromArray:array];
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Open page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.openIssues = array;
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Closed page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.closedIssues = array;
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (!self.milestone) {
        return 0;
    }
    return kUITableViewControllerNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewControllerSectionInfo) {
        return 1;
    } else if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"MilestoneCell";
            
            GHAPIMilestoneV3TableViewCell *cell = (GHAPIMilestoneV3TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHAPIMilestoneV3TableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            GHAPIMilestoneV3 *milestone = self.milestone;
            
            cell.textLabel.text = milestone.title;
            cell.detailTextLabel.text = milestone.dueFormattedString;
            cell.progressView.progress = [milestone.closedIssues floatValue] / ([milestone.closedIssues floatValue] + [milestone.openIssues floatValue]);
            
            if (milestone.dueInTime) {
                [cell.progressView setTintColor:[UIColor greenColor] ];
            } else {
                [cell.progressView setTintColor:[UIColor redColor] ];
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
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

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
        
        GHIssueViewController *issueViewController = [[[GHIssueViewController alloc] initWithRepository:self.repository 
                                                                                                              issueNumber:issue.number]
                                                               autorelease];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
        
        GHIssueViewController *issueViewController = [[[GHIssueViewController alloc] initWithRepository:self.repository 
                                                                                                              issueNumber:issue.number]
                                                               autorelease];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - caching

- (void)cacheHeightForOpenIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.openIssues) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:issue.title] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoOpenIssues] ];
        i++;
    }
}

- (void)cacheHeightForClosedIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.closedIssues) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:issue.title] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoClosedIssues] ];
        i++;
    }
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_milestone forKey:@"milestone"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_milestoneNumber forKey:@"milestoneNumber"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_closedIssues forKey:@"closedIssues"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _milestone = [[decoder decodeObjectForKey:@"milestone"] retain];
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
        _milestoneNumber = [[decoder decodeObjectForKey:@"milestoneNumber"] retain];
        _openIssues = [[decoder decodeObjectForKey:@"openIssues"] retain];
        _closedIssues = [[decoder decodeObjectForKey:@"closedIssues"] retain];
    }
    return self;
}

@end
