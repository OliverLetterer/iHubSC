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
#import "GHLabelTableViewCell.h"
#import "GHPLabelTableViewCell.h"
#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"

#define kUITableViewSectionTitle        0
#define kUITableViewSectionAssigned     1
#define kUITableViewSectionMilestones   2
#define kUITableViewSectionLabels       3

#define kUITableViewNumberOfSections    4


NSInteger const kGHCreateIssueTableViewControllerSectionTitle = kUITableViewSectionTitle;
NSInteger const kGHCreateIssueTableViewControllerSectionAssignee = kUITableViewSectionAssigned;
NSInteger const kGHCreateIssueTableViewControllerSectionMilestones = kUITableViewSectionMilestones;
NSInteger const kGHCreateIssueTableViewControllerSectionLabels = kUITableViewSectionLabels;


@implementation GHCreateIssueTableViewController

@synthesize delegate=_delegate;
@synthesize repository=_repository;
@synthesize collaborators=_collaborators, milestones=_milestones;
@synthesize assigneeString=_assigneeString, selectedMilestoneNumber=_selectedMilestoneNumber;
@synthesize labels=_labels, selectedLabels=_selectedLabels;

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

- (NSMutableArray *)selectedLabels {
    if (!_selectedLabels) {
        _selectedLabels = [NSMutableArray array];
    }
    return _selectedLabels;
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super init])) {
        // Custom initialization
        self.title = NSLocalizedString(@"New Issue", @"");
        self.repository = repository;
    }
    return self;
}

#pragma mark - target actions

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    NSString *title = _issueTitle;
    NSString *body = _issueDescription;
    
    self.navigationItem.rightBarButtonItem = self.loadingButton;
    [GHAPIIssueV3 createIssueOnRepository:self.repository 
                                    title:title body:body assignee:self.assigneeString milestone:self.selectedMilestoneNumber 
                                   labels:self.selectedLabels 
                        completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            self.navigationItem.rightBarButtonItem = self.saveButton;
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

#pragma mark - instance methods

- (void)titleTextFieldValueChanged:(UITextField *)textField
{
    _issueTitle = textField.text;
}

- (void)downloadDataWithDownloadBlock:(void(^)(void))downloadBlock forTableView:(UIExpandableTableView *)tableView inSection:(NSUInteger)section {
    if (!_hasCollaboratorState) {
        [GHAPIRepositoryV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
         collaboratorOnRepository:self.repository 
                completionHandler:^(BOOL state, NSError *error) {
                    if (error) {
                        [self handleError:error];
                        [tableView cancelDownloadInSection:section];
                    } else {
                        _hasCollaboratorState = YES;
                        _isCollaborator = state || [self.repository hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
                        
                        if (_isCollaborator) {
                            downloadBlock();
                        } else {
                            [tableView reloadData];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                            message:NSLocalizedString(@"You need to be a Collaborator on this Repository to perform this action!", @"") 
                                                                           delegate:nil 
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                }];
    } else if (_isCollaborator) {
        downloadBlock();
    }
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionAssigned || section == kUITableViewSectionMilestones || section == kUITableViewSectionLabels;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        return self.collaborators == nil || !_hasCollaboratorState;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones == nil || !_hasCollaboratorState;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels == nil || !_hasCollaboratorState;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    static NSString *CellIdentifier = @"UITableViewCell<UIExpandingTableViewCell>";
    
    UITableViewCell<UIExpandingTableViewCell> *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    } else {
        if (cell == nil) {
            cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
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
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone (%@)", @""), milestone.title ? milestone.title : self.selectedMilestoneNumber];
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Milestone", @"");
        }
    } else if (section == kUITableViewSectionLabels) {
        cell.textLabel.text = NSLocalizedString(@"Labels", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        [self downloadDataWithDownloadBlock:^(void) {
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
        } forTableView:tableView inSection:section];
        
    } else if (section == kUITableViewSectionMilestones) {
        [self downloadDataWithDownloadBlock:^(void) {
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
        } forTableView:tableView inSection:section];   
    } else if (section == kUITableViewSectionLabels) {
        [self downloadDataWithDownloadBlock:^(void) {
            [GHAPIRepositoryV3 labelsOnRepository:self.repository page:1 
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                        [tableView cancelDownloadInSection:section];
                                    } else {
                                        self.labels = array;
                                        [self setNextPage:nextPage forSection:section];
                                        [tableView expandSection:section animated:YES];
                                    }
                                }];
        } forTableView:tableView inSection:section];
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
    } else if (section == kUITableViewSectionLabels) {
        [GHAPIRepositoryV3 labelsOnRepository:self.repository page:page 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [self.labels addObjectsFromArray:array];
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
    if (_hasCollaboratorState && !_isCollaborator) {
        return 1;
    }
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionTitle) {
        return 1;
    } else if (section == kUITableViewSectionAssigned) {
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    } else if (section == kUITableViewSectionLabels) {
        return self.labels.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionTitle) {
        if (indexPath.row == 0) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                static NSString *CellIdentifier = @"GHPCreateIssueTitleAndDescriptionTableViewCell";
                
                GHPCreateIssueTitleAndDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPCreateIssueTitleAndDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    [cell.textField addTarget:self action:@selector(titleTextFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
                    cell.delegate = self;
                }
                
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                static NSString *CellIdentifier = @"GHCreateIssueTableViewCell";
                
                GHCreateIssueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHCreateIssueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    [cell.titleTextField addTarget:self action:@selector(titleTextFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
                    cell.delegate = self;
                }
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
                
                return cell;
            }
        }
    } else if (indexPath.section == kUITableViewSectionAssigned) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
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
        } else {
            static NSString *CellIdentifier = @"UserCell";
            
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
        }
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
            GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
            
            GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row - 1];
            
            if (self.selectedMilestoneNumber && [milestone.number isEqualToNumber:self.selectedMilestoneNumber]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = milestone.title;
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"MilestoneCell";
            
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
    } else if (indexPath.section == kUITableViewSectionLabels) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSString *CellIdentifier = @"GHLabelTableViewCell";
            
            GHPLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row - 1];
            
            if ([self.selectedLabels containsObject:label.name]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = label.name;
            cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"GHLabelTableViewCell";
            
            GHLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row - 1];
            
            if ([self.selectedLabels containsObject:label.name]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = label.name;
            cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
            
            return cell;
        }
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
        if ([self.assigneeString isEqualToString:user.login]) {
            self.assigneeString = nil;
        } else {
            self.assigneeString = user.login;
        }
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row-1];
        if ([self.selectedMilestoneNumber isEqualToNumber:milestone.number]) {
            self.selectedMilestoneNumber = nil;
        } else {
            self.selectedMilestoneNumber = milestone.number;
        }
    } else if (indexPath.section == kUITableViewSectionLabels) {
        GHAPILabelV3 *label = [self.labels objectAtIndex:indexPath.row-1];
        if ([self.selectedLabels containsObject:label.name]) {
            [self.selectedLabels removeObject:label.name];
        } else {
            [self.selectedLabels addObject:label.name];
        }
        [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - GHNewCommentTableViewCellDelegate

- (void)newCommentTableViewCell:(GHNewCommentTableViewCell *)cell didEnterText:(NSString *)text
{
    _issueDescription = text;
}

@end
