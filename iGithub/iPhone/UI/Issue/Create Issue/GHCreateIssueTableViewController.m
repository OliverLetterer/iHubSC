//
//  GHCreateIssueTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateIssueTableViewController.h"
#import "GHCreateIssueTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"

#define kUITableViewSectionTitle 0
#define kUITableViewSectionAssigned 1
#define kUITableViewSectionMilestones 2

@implementation GHCreateIssueTableViewController

@synthesize delegate=_delegate;
@synthesize repository=_repository;
@synthesize collaborators=_collaborators, milestones=_milestones;
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

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"New Issue", @"");
        self.repository = repository;
    }
    return self;
}

#pragma mark - target actions

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    GHCreateIssueTableViewCell *cell = (GHCreateIssueTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionTitle] ];
    
    [GHAPIIssueV3 createIssueOnRepository:self.repository title:cell.titleTextField.text 
                                  body:cell.textView.text assignee:self.assigneeString milestone:self.selectedMilestoneNumber 
                     completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             [self.delegate createIssueViewController:self didCreateIssue:issue];
                         }
                     }];
}

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createIssueViewControllerDidCancel:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                   target:self 
                                                                                   action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                 target:self 
                                                                                 action:@selector(saveButtonClicked:)];
    self.navigationItem.rightBarButtonItem = saveButton;
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
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionTitle) {
        return 1;
    } else if (section == kUITableViewSectionAssigned) {
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionTitle) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHCreateIssueTableViewCell";
            
            GHCreateIssueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHCreateIssueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAssigned) {
        NSString *CellIdentifier = @"UserCell";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
        NSString *CellIdentifier = @"MilestoneCell";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
    if (indexPath.section == kUITableViewSectionTitle) {
        return 200.0f;
    }
    
    return 44.0f;
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_collaborators forKey:@"collaborators"];
    [encoder encodeObject:_assigneeString forKey:@"_assigneeString"];
    [encoder encodeBool:_hasCollaboratorState forKey:@"hasCollaboratorState"];
    [encoder encodeBool:_isCollaborator forKey:@"isCollaborator"];
    [encoder encodeObject:_milestones forKey:@"milestones"];
    [encoder encodeObject:_selectedMilestoneNumber forKey:@"_selectedMilestoneNumber"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _collaborators = [decoder decodeObjectForKey:@"collaborators"];
        _assigneeString = [decoder decodeObjectForKey:@"_assigneeString"];
        _hasCollaboratorState = [decoder decodeBoolForKey:@"hasCollaboratorState"];
        _isCollaborator = [decoder decodeBoolForKey:@"isCollaborator"];
        _milestones = [decoder decodeObjectForKey:@"milestones"];
        _selectedMilestoneNumber = [decoder decodeObjectForKey:@"_selectedMilestoneNumber"];
    }
    return self;
}

@end
