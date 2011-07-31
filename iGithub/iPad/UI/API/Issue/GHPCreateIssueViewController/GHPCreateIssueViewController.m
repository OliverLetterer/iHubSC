//
//  GHPCreateIssueViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCreateIssueViewController.h"
#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"

#define kUITableViewSectionTitleAndDescription      0
#define kUITableViewSectionAssigned                 1
#define kUITableViewSectionMilestones               2

#define kUITableViewNumberOfSections                3

@implementation GHPCreateIssueViewController
@synthesize delegate=_delegate, collaborators=_collaborators, milestones=_milestones, repository=_repository;
@synthesize assigneeString=_assigneeString, selectedMilestoneNumber=_selectedMilestoneNumber;

#pragma mark - setters and getters

- (void)setAssigneeString:(NSString *)assigneeString {
    _assigneeString = [assigneeString copy];
    
    if (self.isViewLoaded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionAssigned] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setSelectedMilestoneNumber:(NSNumber *)selectedMilestoneNumber {
    _selectedMilestoneNumber = [selectedMilestoneNumber copy];
    
    if (self.isViewLoaded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionMilestones] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository delegate:(id<GHPCreateIssueViewControllerDelegate>)delegate {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Create a new Issue", @"");
        self.repository = repository;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - target actions

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createIssueViewControllerIsDone:self];
}

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    GHPCreateIssueTitleAndDescriptionTableViewCell *cell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionTitleAndDescription] ];
    
    [GHAPIIssueV3 createIssueOnRepository:self.repository title:cell.textField.text 
                                     body:cell.textView.text assignee:self.assigneeString milestone:self.selectedMilestoneNumber 
                        completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                [self handleError:error];
                            } else {
                                [self.delegate createIssueViewController:self didCreateIssue:issue];
                            }
                        }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked:)];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionAssigned || section == kUITableViewSectionMilestones;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        return self.collaborators == nil;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones == nil && !_hasCollaboratorState;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionAssigned) {
        if (self.assigneeString) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ is assigned", @""), self.assigneeString];
        } else {
            cell.textLabel.text = NSLocalizedString(@"No one is assigned", @"");
        }
    } else if (section == kUITableViewSectionMilestones) {
        if (self.selectedMilestoneNumber) {
            __block GHAPIMilestoneV3 *milestone = nil;
            [self.milestones enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                GHAPIMilestoneV3 *theMilestone = obj;
                if ([theMilestone.number isEqualToNumber:self.selectedMilestoneNumber]) {
                    milestone = theMilestone;
                    *stop = YES;
                }
            }];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone (%@)", @""), milestone.title];
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Milestone", @"");
        }
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repository page:1 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                            [tableView cancelDownloadInSection:section];
                                        } else {
                                            self.collaborators = array;
                                            [self setNextPage:nextPage forSection:section];
                                            [tableView expandSection:section animated:YES];
                                        }
                                    }];
    } else if (section == kUITableViewSectionMilestones) {
        [GHAPIRepositoryV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
         collaboratorOnRepository:self.repository 
                completionHandler:^(BOOL state, NSError *error) {
                    if (error) {
                        [self handleError:error];
                        [tableView cancelDownloadInSection:section];
                    } else {
                        _hasCollaboratorState = YES;
                        _isCollaborator = state;
                        
                        if (_isCollaborator || [self.repository hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ]) {
                            [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:1 
                                                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                                           if (error) {
                                                               [self handleError:error];
                                                               [tableView cancelDownloadInSection:section];
                                                           } else {
                                                               self.milestones = array;
                                                               [self setNextPage:nextPage forSection:section];
                                                               [tableView expandSection:section animated:YES];
                                                           }
                                                       }];
                        } else {
                            [tableView cancelDownloadInSection:section];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                             message:NSLocalizedString(@"You are not a Collaborator on this Repository. You don't have permission to assign a Milestone!", @"") 
                                                                            delegate:nil 
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                   otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                }];
    }
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionMilestones) {
        [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:page 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           [self.milestones addObjectsFromArray:array];
                                           [self setNextPage:nextPage forSection:section];
                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                   }];
    } else if (section == kUITableViewSectionAssigned) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repository page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            [self.collaborators addObjectsFromArray:array];
                                            [self setNextPage:nextPage forSection:section];
                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
                                    }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionTitleAndDescription) {
        return 1;
    } else if (section == kUITableViewSectionAssigned) {
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionTitleAndDescription) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHPCreateIssueTitleAndDescriptionTableViewCell";
            
            GHPCreateIssueTitleAndDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPCreateIssueTitleAndDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAssigned) {
        NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
        
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row - 1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        if ([user.login isEqualToString:self.assigneeString]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = user.login;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
        
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row - 1];
        
        if (self.selectedMilestoneNumber && [milestone.number isEqualToNumber:self.selectedMilestoneNumber]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = milestone.title;
        
        return cell;
    }
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 200.0f;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionAssigned) {
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row-1];
        self.assigneeString = user.login;
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row-1];
        self.selectedMilestoneNumber = milestone.number;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
