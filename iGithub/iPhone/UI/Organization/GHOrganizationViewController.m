//
//  GHOrganizationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOrganizationViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "GHWebViewViewController.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHRepositoryViewController.h"
#import "GHUserViewController.h"
#import "GHTeamViewController.h"
#import "GHRecentActivityViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewSectionInfo                 0
#define kUITableViewSectionEMail                1
#define kUITableViewSectionLocation             2
#define kUITableViewSectionBlog                 3
#define kUITableViewSectionPublicActivity       4
#define kUITableViewSectionPublicRepositories   5
#define kUITableViewSectionPublicMembers        6
#define kUITableViewSectionTeams                7

#define kUITableViewNumberOfSections            8

@implementation GHOrganizationViewController

@synthesize organizationLogin=_organizationLogin;
@synthesize organization=_organization;
@synthesize publicRepositories=_publicRepositories, publicMembers=_publicMembers, teams=_teams;

- (void)setOrganizationLogin:(NSString *)organizationLogin {
    _organizationLogin = [organizationLogin copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIOrganizationV3 organizationByName:_organizationLogin 
                          completionHandler:^(GHAPIOrganizationV3 *organization, NSError *error) {
                              self.isDownloadingEssentialData = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.organization = organization;
                                  if ([self isViewLoaded]) {
                                      [self.tableView reloadData];
                                  }
                                  self.title = self.organization.name ? self.organization.name : self.organization.login;
                              }
                          }];
}

#pragma mark - Initialization

- (id)initWithOrganizationLogin:(NSString *)organizationLogin {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.organizationLogin = organizationLogin;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.organization.name ? self.organization.name : self.organization.login;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionPublicRepositories || section == kUITableViewSectionPublicMembers || section == kUITableViewSectionTeams;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionPublicRepositories) {
        return self.publicRepositories == nil;
    } else if (section == kUITableViewSectionPublicMembers) {
        return self.publicMembers == nil;
    } else if (section == kUITableViewSectionTeams) {
        return self.teams == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == kUITableViewSectionPublicRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Public Repositories", @"");
    } else if (section == kUITableViewSectionPublicMembers) {
        cell.textLabel.text = NSLocalizedString(@"Public Members", @"");
    } else if (section == kUITableViewSectionTeams) {
        cell.textLabel.text = NSLocalizedString(@"Teams", @"");
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionPublicRepositories) {
        [GHAPIOrganizationV3 repositoriesOfOrganizationNamed:self.organization.login page:page 
                                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                                if (error) {
                                                    [self handleError:error];
                                                } else {
                                                    [self.publicRepositories addObjectsFromArray:array];
                                                    [self setNextPage:nextPage forSection:section];
                                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                                                }
                                            }];
    } else if (section == kUITableViewSectionPublicMembers) {
        [GHAPIOrganizationV3 membersOfOrganizationNamed:self.organization.login page:1 
                                      completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                          if (error) {
                                              [self handleError:error];
                                          } else {
                                              [self.publicMembers addObjectsFromArray:array];
                                              [self setNextPage:nextPage forSection:section];
                                              [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                            withRowAnimation:UITableViewRowAnimationAutomatic];
                                          }
                                      }];
    } else if (section == kUITableViewSectionTeams) {
        [GHAPIOrganizationV3 teamsOfOrganizationNamed:self.organization.login page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            [self.teams addObjectsFromArray:array];
                                            [self setNextPage:nextPage forSection:section];
                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
                                    }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionPublicRepositories) {
        [GHAPIOrganizationV3 repositoriesOfOrganizationNamed:self.organization.login page:1 
                                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                                if (error) {
                                                    [self handleError:error];
                                                    [tableView cancelDownloadInSection:section];
                                                } else {
                                                    self.publicRepositories = array;
                                                    [self setNextPage:nextPage forSection:section];
                                                    [tableView expandSection:section animated:YES];
                                                }
                                            }];
    } else if (section == kUITableViewSectionPublicMembers) {
        [GHAPIOrganizationV3 membersOfOrganizationNamed:self.organization.login page:1 
                                      completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                          if (error) {
                                              [self handleError:error];
                                              [tableView cancelDownloadInSection:section];
                                          } else {
                                              self.publicMembers = array;
                                              [self setNextPage:nextPage forSection:section];
                                              [tableView expandSection:section animated:YES];
                                          }
                                      }];
    } else if (section == kUITableViewSectionTeams) {
        [GHAPIOrganizationV3 teamsOfOrganizationNamed:self.organization.login page:1 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                            [tableView cancelDownloadInSection:section];
                                        } else {
                                            self.teams = array;
                                            [self setNextPage:nextPage forSection:section];
                                            [tableView expandSection:section animated:YES];
                                            
                                            if (self.teams.count == 0) {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Teams", @"") 
                                                                                                 message:NSLocalizedString(@"There are no Teams available for this Organization", @"")
                                                                                                delegate:nil 
                                                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                       otherButtonTitles:nil];
                                                [alert show];
                                            }
                                        }
                                    }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.organization) {
        return 0;
    }
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionInfo) {
        return 1;
    } else if (section == kUITableViewSectionEMail) {
        if (self.organization.hasEMail) {
            return 1;
        }
    } else if (section == kUITableViewSectionLocation) {
        if (self.organization.hasLocation) {
            return 1;
        }
    } else if (section == kUITableViewSectionBlog) {
        if (self.organization.hasBlog) {
            return 1;
        }
    } else if (section == kUITableViewSectionPublicActivity) {
        return 1;
    } else if (section == kUITableViewSectionPublicRepositories) {
        return self.publicRepositories.count + 1;
    } else if (section == kUITableViewSectionPublicMembers) {
        return self.publicMembers.count + 1;
    } else if (section == kUITableViewSectionTeams) {
        return self.teams.count + 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"TitleTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = self.organization.login;
            cell.descriptionLabel.text = nil;
            cell.detailTextLabel.text = nil;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.organization.avatarURL];
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionEMail) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = NSLocalizedString(@"E-Mail", @"");
            cell.detailTextLabel.text = self.organization.EMail;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionLocation) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = NSLocalizedString(@"Location", @"");
            cell.detailTextLabel.text = self.organization.location;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionBlog) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Blog", @"");
            cell.detailTextLabel.text = self.organization.blog;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPublicActivity) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = NSLocalizedString(@"Public", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Activity", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIRepositoryV3 *repository = [self.publicRepositories objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner.login, repository.name];
        
        cell.descriptionLabel.text = repository.description;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionPublicMembers) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        GHAPIUserV3 *user = [self.publicMembers objectAtIndex:indexPath.row - 1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionTeams) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        GHAPITeamV3 *team = [self.teams objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = team.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return 71.0f;
        }
        return 44.0f;
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        GHAPIRepositoryV3 *repository = [self.publicRepositories objectAtIndex:indexPath.row-1];
        return [GHDescriptionTableViewCell heightWithContent:repository.description];
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionBlog && indexPath.row == 0) {
        NSURL *URL = [NSURL URLWithString:self.organization.blog];
        GHWebViewViewController *web = [[GHWebViewViewController alloc] initWithURL:URL];
        [self.navigationController pushViewController:web animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicActivity && indexPath.row == 0) {
        GHRecentActivityViewController *recentViewController = [[GHRecentActivityViewController alloc] initWithUsername:self.organization.login];
        [self.navigationController pushViewController:recentViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        GHAPIRepositoryV3 *repo = [self.publicRepositories objectAtIndex:indexPath.row-1];
        
        GHRepositoryViewController *viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name] ];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicMembers) {
        GHAPIUserV3 *user = [self.publicMembers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionTeams) {
        GHAPITeamV3 *team = [self.teams objectAtIndex:indexPath.row - 1];
        
        GHTeamViewController *teamViewController = [[GHTeamViewController alloc] initWithTeamID:team.ID organization:self.organizationLogin];
        [self.navigationController pushViewController:teamViewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_organizationLogin forKey:@"organizationLogin"];
    [encoder encodeObject:_organization forKey:@"organization"];
    [encoder encodeObject:_publicRepositories forKey:@"publicRepositories"];
    [encoder encodeObject:_publicMembers forKey:@"publicMembers"];
    [encoder encodeObject:_teams forKey:@"teams"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _organizationLogin = [decoder decodeObjectForKey:@"organizationLogin"];
        _organization = [decoder decodeObjectForKey:@"organization"];
        _publicRepositories = [decoder decodeObjectForKey:@"publicRepositories"];
        _publicMembers = [decoder decodeObjectForKey:@"publicMembers"];
        _teams = [decoder decodeObjectForKey:@"teams"];
    }
    return self;
}

#pragma mark - GHCreateTeamViewControllerDelegate

- (void)createTeamViewControllerDidCancel:(GHCreateTeamViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTeamViewController:(GHCreateTeamViewController *)createViewController didCreateTeam:(GHAPITeamV3 *)team {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Team", @"") message:team.name];
    [self.teams addObject:team];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionTeams] withRowAnimation:UITableViewRowAnimationNone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = nil;
    @try {
        title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    @catch (NSException *exception) {}
    
    if ([title isEqualToString:NSLocalizedString(@"Add Team", @"")]) {
        GHCreateTeamViewController *viewController = [[GHCreateTeamViewController alloc] initWithOrganization:self.organizationLogin];
        viewController.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentModalViewController:navController animated:YES];
    } else if ([title isEqualToString:NSLocalizedString(@"View Blog in Safari", @"")]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.organization.blog] ];
    } else if ([title isEqualToString:NSLocalizedString(@"E-Mail", @"")]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:self.organization.EMail]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    [GHAPIOrganizationV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login administratorInOrganization:self.organizationLogin completionHandler:^(BOOL state, NSError *error) {
        if (error) {
            [self failedToDownloadDataToDisplayActionButtonWithError:error];
        } else {
            _hasAdminData = YES;
            _isAdmin = state;
            [self didDownloadDataToDisplayActionButton];
        }
    }];
}

- (UIActionSheet *)actionButtonActionSheet {
    if (!_isAdmin) {
        return nil;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.organizationLogin;
    NSUInteger currentButtonIndex = 0;
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Add Team", @"")];
    currentButtonIndex++;
    
    if (self.organization.hasBlog) {
        [sheet addButtonWithTitle:NSLocalizedString(@"View Blog in Safari", @"")];
        currentButtonIndex++;
    }
    if (self.organization.hasEMail && [MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"E-Mail", @"")];
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

@end
