//
//  GHCreateTeamViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateTeamViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPUserTableViewCell.h"

NSInteger const kGHCreateTeamViewControllerTableViewSectionTitle            = 0;
NSInteger const kGHCreateTeamViewControllerTableViewSectionPermission       = 1;
NSInteger const kGHCreateTeamViewControllerTableViewSectionRepositories     = 2;
NSInteger const kGHCreateTeamViewControllerTableViewSectionMembers          = 3;

NSInteger const kGHCreateTeamViewControllerTableViewNumberOfSections        = 4;



NSString *NSStringFromGHAPITeamPermissionV3(NSString *GHAPITeamPermissionV3) {
    if ([GHAPITeamPermissionV3 isEqualToString:GHAPITeamV3PermissionPull]) {
        return NSLocalizedString(@"Pull only", @"");
    } else if ([GHAPITeamPermissionV3 isEqualToString:GHAPITeamV3PermissionPush]) {
        return NSLocalizedString(@"Push & Pull", @"");
    } else if ([GHAPITeamPermissionV3 isEqualToString:GHAPITeamV3PermissionAdmin]) {
        return NSLocalizedString(@"Push, Pull & Administrative", @"");
    }
    return @"";
}

@implementation GHCreateTeamViewController
@synthesize delegate=_delegate, organization=_organization;
@synthesize selectedPermission=_selectedPermission;

#pragma mark - setters and getters

- (void)setSelectedPermission:(NSString *)selectedPermission {
    if (selectedPermission != _selectedPermission) {
        _selectedPermission = [selectedPermission copy];
        
        if (self.isViewLoaded) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kGHCreateTeamViewControllerTableViewSectionPermission]
                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (NSArray *)availablePermissions {
    if (!_availablePermissions) {
        _availablePermissions = [NSArray arrayWithObjects:GHAPITeamV3PermissionPull, GHAPITeamV3PermissionPush, GHAPITeamV3PermissionAdmin, nil];
    }
    return _availablePermissions;
}

- (NSMutableArray *)selectedRepositories {
    if (!_selectedRepositories) {
        _selectedRepositories = [NSMutableArray array];
    }
    return _selectedRepositories;
}

- (NSMutableArray *)selectedMembers {
    if (!_selectedMembers) {
        _selectedMembers = [NSMutableArray array];
    }
    return _selectedMembers;
}

#pragma mark - Initialization

- (id)initWithOrganization:(NSString *)organization {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        self.organization = organization;
        self.title = NSLocalizedString(@"Create Team", @"");
        
        self.selectedPermission = GHAPITeamV3PermissionPull;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isPresentedInPopoverController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self 
                                                                                      action:@selector(cancelButtonClicked:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    self.navigationController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                target:self 
                                                                                action:@selector(saveButtonClicked:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kGHCreateTeamViewControllerTableViewSectionPermission || section == kGHCreateTeamViewControllerTableViewSectionRepositories || section == kGHCreateTeamViewControllerTableViewSectionMembers;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        return _repositories == nil;
    } else if (section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        return _members == nil;
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
    
    if (section == kGHCreateTeamViewControllerTableViewSectionPermission) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Permission: %@", @""), self.selectedPermission];
    } else if (section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
    } else if (section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        cell.textLabel.text = NSLocalizedString(@"Members", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        [GHAPIOrganizationV3 repositoriesOfOrganizationNamed:self.organization page:1 
                                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                               if (error) {
                                                   [self handleError:error];
                                                   [tableView cancelDownloadInSection:section];
                                               } else {
                                                   _repositories = array;
                                                   [self setNextPage:nextPage forSection:section];
                                                   [tableView expandSection:section animated:YES];
                                               }
                                           }];
    } else if (section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        [GHAPIOrganizationV3 membersOfOrganizationNamed:self.organization page:1 
                                      completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                          if (error) {
                                              [self handleError:error];
                                              [tableView cancelDownloadInSection:section];
                                          } else {
                                              _members = array;
                                              [self setNextPage:nextPage forSection:section];
                                              [tableView expandSection:section animated:YES];
                                          }
                                      }];
    }
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        [GHAPIOrganizationV3 repositoriesOfOrganizationNamed:self.organization page:page 
                                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                               if (error) {
                                                   [self handleError:error];
                                               } else {
                                                   [_repositories addObjectsFromArray:array];
                                                   [self setNextPage:nextPage forSection:section];
                                                   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                               }
                                           }];
    } else if (section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        [GHAPIOrganizationV3 membersOfOrganizationNamed:self.organization page:page 
                                      completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                          if (error) {
                                              [self handleError:error];
                                          } else {
                                              [_members addObjectsFromArray:array];
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
    return kGHCreateTeamViewControllerTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kGHCreateTeamViewControllerTableViewSectionPermission) {
        return self.availablePermissions.count + 1;
    } else if (section == kGHCreateTeamViewControllerTableViewSectionTitle) {
        return 1;
    } else if (section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        return _repositories.count + 1;
    } else if (section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        return _members.count + 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionPermission) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
            GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            NSString *permission = [self.availablePermissions objectAtIndex:indexPath.row-1];
            cell.textLabel.text = NSStringFromGHAPITeamPermissionV3(permission);
            
            if ([permission isEqualToString:self.selectedPermission]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"MilestoneCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            NSString *permission = [self.availablePermissions objectAtIndex:indexPath.row-1];
            cell.textLabel.text = NSStringFromGHAPITeamPermissionV3(permission);
            
            if ([permission isEqualToString:self.selectedPermission]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        }
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionTitle) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"GHPTextFieldTableViewCell";
            
            GHPTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"GHTextFieldTableViewCell";
            
            GHTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        }
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
            
            GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIRepositoryV3 *repository = [_repositories objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = repository.fullRepositoryName;
            cell.detailTextLabel.text = repository.description;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            if ([self.selectedRepositories containsObject:repository.fullRepositoryName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIRepositoryV3 *repository = [_repositories objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = repository.fullRepositoryName;
            cell.descriptionLabel.text = repository.description;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            if ([self.selectedRepositories containsObject:repository.fullRepositoryName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        }
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        if (indexPath.row == 1) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                static NSString *CellIdentifier = @"newmembercell";
                
                GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
                
                cell.textLabel.text = NSLocalizedString(@"Other User", @"");
                
                return cell;
            } else {
                static NSString *CellIdentifier = @"newmembercell";
                
                GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.text = NSLocalizedString(@"Other User", @"");
                
                return cell;
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                static NSString *CellIdentifier = @"GHPUserTableViewCell";
                
                GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                GHAPIUserV3 *user = [_members objectAtIndex:indexPath.row-2];
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
                cell.textLabel.text = user.login;
                
                if ([self.selectedMembers containsObject:user.login]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                return cell;
            } else {
                static NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
                
                GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                GHAPIUserV3 *user = [_members objectAtIndex:indexPath.row-2];
                
                [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
                cell.textLabel.text = user.login;
                
                if ([self.selectedMembers containsObject:user.login]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                return cell;
            }
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionPermission) {
        self.selectedPermission = [self.availablePermissions objectAtIndex:indexPath.row-1];
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionRepositories) {
        GHAPIRepositoryV3 *repository = [_repositories objectAtIndex:indexPath.row-1];
        if ([self.selectedRepositories containsObject:repository.fullRepositoryName]) {
            [self.selectedRepositories removeObject:repository.fullRepositoryName];
        } else {
            [self.selectedRepositories addObject:repository.fullRepositoryName];
        }
        [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionMembers) {
        if (indexPath.row > 1) {
            GHAPIUserV3 *user = [_members objectAtIndex:indexPath.row-2];
            if ([self.selectedMembers containsObject:user.login]) {
                [self.selectedMembers removeObject:user.login];
            } else {
                [self.selectedMembers addObject:user.login];
            }
            [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Username", @"") 
                                                             message:NSLocalizedString(@"", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Add", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionRepositories && indexPath.row > 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            GHAPIRepositoryV3 *repository = [_repositories objectAtIndex:indexPath.row-1];
            return [GHPRepositoryTableViewCell heightWithContent:repository.description];
        } else {
            GHAPIRepositoryV3 *repository = [_repositories objectAtIndex:indexPath.row-1];
            return [GHDescriptionTableViewCell heightWithContent:repository.description];
        }
    } else if (indexPath.section == kGHCreateTeamViewControllerTableViewSectionMembers && indexPath.row > 1) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return GHPUserTableViewCellHeight;
        } else {
            return 44.0f;
        }
    }
    return 44.0f;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        [GHAPIUserV3 userWithName:username completionHandler:^(GHAPIUserV3 *user, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                [_members addObject:user];
                [self.selectedMembers addObject:user.login];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kGHCreateTeamViewControllerTableViewSectionMembers] 
                              withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

#pragma mark - target actions

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    NSString *name = nil;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GHPTextFieldTableViewCell *cell = (GHPTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateTeamViewControllerTableViewSectionTitle] ];
        
        name = cell.textField.text;
    } else {
        GHTextFieldTableViewCell *cell = (GHTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateTeamViewControllerTableViewSectionTitle] ];
        
        name = cell.textField.text;
    }
    
    [GHAPIOrganizationV3 createTeamForOrganization:self.organization name:name permission:self.selectedPermission repositories:_selectedRepositories teamMembers:_selectedMembers completionHandler:^(GHAPITeamV3 *team, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            [self.delegate createTeamViewController:self didCreateTeam:team];
        }
    }];
}

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createTeamViewControllerDidCancel:self];
}

@end
