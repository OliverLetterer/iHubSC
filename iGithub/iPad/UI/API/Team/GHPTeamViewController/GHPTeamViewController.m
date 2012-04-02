//
//  GHPTeamViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPTeamViewController.h"
#import "GHPUserTableViewCell.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPUserViewController.h"
#import "GHPRepositoryViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewSectionInfo             0
#define kUITableViewSectionMembers          1
#define kUITableViewSectionRepositories     2

#define kUITableViewNumberOfSections        3

@implementation GHPTeamViewController
@synthesize team=_team, teamID=_teamID, members=_members, repositories=_repositories, organization=_organization;

- (void)setTeamID:(NSNumber *)teamID {
    _teamID = [teamID copy];
    
    [GHAPITeamV3 teamByID:_teamID 
        completionHandler:^(GHAPITeamV3 *team, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                self.team = team;
            }
        }];
}

- (void)setTeam:(GHAPITeamV3 *)team {
    if (team != _team) {
        _team = team;
        
        self.title = _team.name;
        self.members = nil;
        self.repositories = nil;
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithTeamID:(NSNumber *)teamID organization:(NSString *)organization {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.teamID = teamID;
        self.organization = organization;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionMembers || section == kUITableViewSectionRepositories;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionMembers) {
        return self.members == nil;
    } else if (section == kUITableViewSectionRepositories) {
        return self.repositories == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionMembers) {
        cell.textLabel.text = NSLocalizedString(@"Members", @"");
    } else if (section == kUITableViewSectionRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionMembers) {
        [GHAPITeamV3 membersOfTeamByID:self.teamID page:1 
                     completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             [self.members addObjectsFromArray:array];
                             [self setNextPage:nextPage forSection:section];
                             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                         }
                     }];
    } else if (section == kUITableViewSectionRepositories) {
        [GHAPITeamV3 repositoriesOfTeamByID:self.teamID page:page 
                          completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  [self.repositories addObjectsFromArray:array];
                                  [self setNextPage:nextPage forSection:section];
                                  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                withRowAnimation:UITableViewRowAnimationAutomatic];
                              }
                          }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionMembers) {
        [GHAPITeamV3 membersOfTeamByID:self.teamID page:1 
                     completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                         if (error) {
                             [self handleError:error];
                             [tableView cancelDownloadInSection:section];
                         } else {
                             self.members = array;
                             [self setNextPage:nextPage forSection:section];
                             [tableView expandSection:section animated:YES];
                         }
                     }];
    } else if (section == kUITableViewSectionRepositories) {
        [GHAPITeamV3 repositoriesOfTeamByID:self.teamID page:1 
                          completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                                  [tableView cancelDownloadInSection:section];
                              } else {
                                  self.repositories = array;
                                  [self setNextPage:nextPage forSection:section];
                                  [tableView expandSection:section animated:YES];
                              }
                          }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.team) {
        return 0;
    }
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionMembers) {
        return self.members.count + 1;
    } else if (section == kUITableViewSectionRepositories) {
        return self.repositories.count + 1;
    } else if (section == kUITableViewSectionInfo) {
        return 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionMembers) {
        static NSString *CellIdentifier = @"GHPUserTableViewCell";
        
        GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPIUserV3 *user = [self.members objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
        
        GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPIRepositoryV3 *repository = [self.repositories objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = repository.fullRepositoryName;
        cell.detailTextLabel.text = repository.description;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionInfo) {
        GHPInfoTableViewCell *cell = self.infoCell;   
        
        cell.textLabel.text = self.team.name;
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionRepositories && indexPath.row > 0) {
        GHAPIRepositoryV3 *repository = [self.repositories objectAtIndex:indexPath.row-1];
        return [GHPRepositoryTableViewCell heightWithContent:repository.description];
    } else if (indexPath.section == kUITableViewSectionMembers && indexPath.row > 0) {
        return GHPUserTableViewCellHeight;
    } else if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return [GHPInfoTableViewCell heightWithContent:nil];
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionMembers && indexPath.row > 0) {
        GHAPIUserV3 *user = [self.members objectAtIndex:indexPath.row - 1];
        
        viewController = [[GHPUserViewController alloc] initWithUsername:user.login];
    } else if (indexPath.section == kUITableViewSectionRepositories && indexPath.row > 0) {
        
        GHAPIRepositoryV3 *repo = [self.repositories objectAtIndex:indexPath.row-1];
        
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:repo.fullRepositoryName];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_team forKey:@"team"];
    [encoder encodeObject:_teamID forKey:@"teamID"];
    [encoder encodeObject:_members forKey:@"members"];
    [encoder encodeObject:_repositories forKey:@"repositories"];
    [encoder encodeObject:_organization forKey:@"_organization"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _team = [decoder decodeObjectForKey:@"team"];
        _teamID = [decoder decodeObjectForKey:@"teamID"];
        _members = [decoder decodeObjectForKey:@"members"];
        _repositories = [decoder decodeObjectForKey:@"repositories"];
        _organization = [decoder decodeObjectForKey:@"_organization"];
    }
    return self;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = nil;
    @try {
        title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    @catch (NSException *exception) {}
    
    if ([title isEqualToString:NSLocalizedString(@"Edit", @"")]) {
        GHEditTeamViewController *viewController = [[GHEditTeamViewController alloc] initWithTeam:self.team organization:self.organization];
        viewController.delegate = self;
        
        if (_isAdmin) {
            viewController.permission = GHEditTeamViewControllerEditingPermissionAll;
        } else {
            viewController.permission = GHEditTeamViewControllerEditingPermissionMembers;
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    } else if ([title isEqualToString:NSLocalizedString(@"Delete", @"")]) {
        [GHAPITeamV3 deleteTeamWithID:self.teamID completionHandler:^(NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully deleted", @"") message:self.team.name];
                [self.advancedNavigationController popViewController:self animated:YES];
            }
        }];
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    [GHAPIOrganizationV3 isUser:username administratorInOrganization:self.organization completionHandler:^(BOOL state, NSError *error) {
        if (error) {
            [self failedToDownloadDataToDisplayActionButtonWithError:error];
        } else {
            _isAdmin = state;
            _canEditTeam = state;
            _hasAdminData = YES;
            
            [self didDownloadDataToDisplayActionButton];
        }
    }];
}

- (UIActionSheet *)actionButtonActionSheet {
    if (!_isAdmin && !_canEditTeam) {
        return nil;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.team.name;
    NSUInteger currentButtonIndex = 0;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Edit", @"")];
    currentButtonIndex++;
    
    if (_isAdmin) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
        sheet.destructiveButtonIndex = currentButtonIndex;
        currentButtonIndex++;
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
    return !_hasAdminData;
}

#pragma mark - GHCreateTeamViewControllerDelegate

- (void)createTeamViewControllerDidCancel:(GHCreateTeamViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTeamViewController:(GHCreateTeamViewController *)createViewController didCreateTeam:(GHAPITeamV3 *)team {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Updated Team", @"") message:team.name];
    self.team = team;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end