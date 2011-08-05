//
//  GHUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUserViewController.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHRepositoryViewController.h"
#import "GHWebViewViewController.h"
#import "NSString+Additions.h"
#import "GHRecentActivityViewController.h"
#import "GHOrganizationViewController.h"
#import "GHGistViewController.h"
#import "ANNotificationQueue.h"
#import "GHIssueViewController.h"
#import "GHManageAuthenticatedUsersAlertView.h"

#define kUITableViewSectionUserData             0
#define kUITableViewSectionEMail                1
#define kUITableViewSectionLocation             2
#define kUITableViewSectionCompany              3
#define kUITableViewSectionBlog                 4
#define kUITableViewSectionPublicActivity       5
#define kUITableViewSectionRepositories         6
#define kUITableViewSectionWatchedRepositories  7
#define kUITableViewFollowingUsers              8
#define kUITableViewFollowedUsers               9
#define kUITableViewGists                       10
#define kUITableViewOrganizations               11
#define kUITableViewSectionPlan                 12

#define kUITableViewNumberOfSections            13

@implementation GHUserViewController

@synthesize repositoriesArray=_repositoriesArray;
@synthesize username=_username, user=_user;
@synthesize watchedRepositoriesArray=_watchedRepositoriesArray, followingUsers=_followingUsers, followedUsers=_followedUsers, organizations=_organizations, gists=_gists;
@synthesize lastIndexPathForSingleRepositoryViewController=_lastIndexPathForSingleRepositoryViewController;

#pragma mark - setters and getters

- (BOOL)canFollowUser {
    return !self.hasAdministrationRights;
}

- (BOOL)hasAdministrationRights {
    return [self.username isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
}

- (void)setUsername:(NSString *)username {
    _username = [username copy];
    self.title = self.username;
    
    self.watchedRepositoriesArray = nil;
    self.repositoriesArray = nil;
    self.user = nil;
    self.followingUsers = nil;
    self.followedUsers = nil;
    
    self.isDownloadingEssentialData = YES;
    [GHAPIUserV3 userWithName:self.username 
            completionHandler:^(GHAPIUserV3 *user, NSError *error) {
                self.isDownloadingEssentialData = NO;
                if (error) {
                    [self handleError:error];
                } else {
                    self.user = user;
                    [self.tableView reloadData];
                }
                [self pullToReleaseTableViewDidReloadData];
            }];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - Notifications

- (void)gistDeletedNotificationCallback:(NSNotification *)notification {
    NSString *gistID = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryGistIDKey];
    NSIndexSet *deleteSet = [self.gists indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        return [gist.ID isEqualToString:gistID];
    }];
    
    [self.gists removeObjectsAtIndexes:deleteSet];
    [self cacheGistsHeight];
    if (self.isViewLoaded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewGists] 
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - instance methods

- (void)downloadRepositories {
    [self.tableView collapseSection:kUITableViewSectionRepositories animated:YES];
    self.repositoriesArray = nil;
    [self.tableView reloadData];
    
    [GHAPIRepositoryV3 repositoriesForUserNamed:self.username page:1 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.repositoriesArray = array;
                                      [self setNextPage:nextPage forSection:kUITableViewSectionRepositories];
                                      [self cacheHeightForTableView];
                                      [self.tableView expandSection:kUITableViewSectionRepositories animated:YES];
                                  }
                              }];
}

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    
    self.repositoriesArray = nil;
    self.watchedRepositoriesArray = nil;
    self.followingUsers = nil;
    self.followedUsers = nil;
    self.organizations = nil;
    self.gists = nil;
    [self.tableView reloadData];
    
    [GHAPIUserV3 userWithName:self.username 
            completionHandler:^(GHAPIUserV3 *user, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    self.user = user;
                    [self.tableView reloadData];
                }
                [self pullToReleaseTableViewDidReloadData];
            }];
}

- (void)cacheHeightForTableView {
    NSInteger i = 0;
    for (GHAPIRepositoryV3 *repo in self.repositoriesArray) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:repo.description] forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionRepositories]];
        
        i++;
    }
}

- (void)cacheHeightForWatchedRepositories {
    NSInteger i = 0;
    for (GHAPIRepositoryV3 *repo in self.watchedRepositoriesArray) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:repo.description] forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionWatchedRepositories]];
        
        i++;
    }
}

- (void)cacheGistsHeight {
    [self.gists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:gist.description] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewGists]];
    }];
}

- (NSString *)descriptionForAssignedIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"on %@\n\n%@", @""), issue.repository, issue.title];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionRepositories || 
            section == kUITableViewSectionWatchedRepositories || 
            section == kUITableViewSectionPlan ||
            section == kUITableViewFollowingUsers ||
            section == kUITableViewFollowedUsers ||
            section == kUITableViewOrganizations ||
            section == kUITableViewGists;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionRepositories) {
        return self.repositoriesArray == nil;
    } else if (section == kUITableViewSectionWatchedRepositories) {
        return self.watchedRepositoriesArray == nil;
    } else if (section == kUITableViewFollowingUsers) {
        return self.followingUsers == nil;
    } else if (section == kUITableViewFollowedUsers) {
        return self.followedUsers == nil;
    } else if (section == kUITableViewOrganizations) {
        return self.organizations == nil;
    } else if (section == kUITableViewGists) {
        return self.gists == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == kUITableViewSectionRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
    } else if (section == kUITableViewSectionWatchedRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Watched Repositories", @"");
    } else if (section == kUITableViewSectionPlan) {
        cell.textLabel.text = NSLocalizedString(@"Plan", @"");
    } else if (section == kUITableViewFollowingUsers) {
        cell.textLabel.text = NSLocalizedString(@"Following", @"");
    } else if (section == kUITableViewFollowedUsers) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User following %@", @""), self.username];
    } else if (section == kUITableViewOrganizations) {
        cell.textLabel.text = NSLocalizedString(@"Organizations", @"");
    } else if (section == kUITableViewGists) {
        cell.textLabel.text = NSLocalizedString(@"Gists", @"");
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [super downloadDataForPage:page inSection:section];
    
    if (section == kUITableViewGists) {
        [GHAPIUserV3 gistsOfUser:self.username 
                            page:page 
               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                   if (error) {
                       [self handleError:error];
                   } else {
                       [self setNextPage:nextPage forSection:section];
                       [self.gists addObjectsFromArray:array];
                       [self cacheGistsHeight];
                       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                     withRowAnimation:UITableViewRowAnimationBottom];
                   }
               }];
    } else if (section == kUITableViewFollowingUsers) {
        [GHAPIUserV3 usersThatUsernameIsFollowing:self.username 
                                             page:page
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self.followingUsers addObjectsFromArray:array];
                                        [self setNextPage:nextPage forSection:section];
                                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                                    }
                                }];
    } else if (section == kUITableViewFollowedUsers) {
        [GHAPIUserV3 usersThatAreFollowingUserNamed:self.username 
                                               page:page 
                                  completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                      if (error) {
                                          [self handleError:error];
                                      } else {
                                          [self.followedUsers addObjectsFromArray:array];
                                          [self setNextPage:nextPage forSection:section];
                                          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                        withRowAnimation:UITableViewRowAnimationAutomatic];
                                      }
                                  }];
    } else if (section == kUITableViewSectionRepositories) {
        [GHAPIRepositoryV3 repositoriesForUserNamed:self.username page:page 
                                  completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                      if (error) {
                                          [self handleError:error];
                                      } else {
                                          [self.repositoriesArray addObjectsFromArray:array];
                                          [self setNextPage:nextPage forSection:section];
                                          [self cacheHeightForTableView];
                                          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                        withRowAnimation:UITableViewRowAnimationAutomatic];
                                      }
                                  }];
    } else if (section == kUITableViewSectionWatchedRepositories) {
        [GHAPIRepositoryV3 repositoriesThatUserIsWatching:self.username page:page 
                                        completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                            if (error) {
                                                [self handleError:error];
                                            } else {
                                                [self.watchedRepositoriesArray addObjectsFromArray:array];
                                                [self setNextPage:nextPage forSection:section];
                                                [self cacheHeightForWatchedRepositories];
                                                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                                            }
                                        }];
    } else if (section == kUITableViewOrganizations) {
        [GHAPIOrganizationV3 organizationsOfUser:self.username page:page 
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self.organizations addObjectsFromArray:array];
                                       [self setNextPage:nextPage forSection:section];
                                       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                   }
                               }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionRepositories) {
        [self downloadRepositories];
    } else if (section == kUITableViewSectionWatchedRepositories) {
        [GHAPIRepositoryV3 repositoriesThatUserIsWatching:self.username page:1 
                                        completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                            if (error) {
                                                [self handleError:error];
                                                [tableView cancelDownloadInSection:section];
                                            } else {
                                                self.watchedRepositoriesArray = array;
                                                [self setNextPage:nextPage forSection:section];
                                                [self cacheHeightForWatchedRepositories];
                                                [self.tableView expandSection:section animated:YES];
                                            }
                                        }];
    } else if (section == kUITableViewFollowingUsers) {
        [GHAPIUserV3 usersThatUsernameIsFollowing:self.username 
                                             page:1 
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                        [tableView cancelDownloadInSection:section];
                                    } else {
                                        self.followingUsers = array;
                                        [self setNextPage:nextPage forSection:section];
                                        [tableView expandSection:section animated:YES];
                                    }
                                }];
    } else if (section == kUITableViewFollowedUsers) {
        [GHAPIUserV3 usersThatAreFollowingUserNamed:self.username 
                                               page:1 
                                  completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                      if (error) {
                                          [self handleError:error];
                                          [tableView cancelDownloadInSection:section];
                                      } else {
                                          self.followedUsers = array;
                                          [self setNextPage:nextPage forSection:section];
                                          [tableView expandSection:section animated:YES];
                                      }
                                  }];
    } else if (section == kUITableViewOrganizations) {
        [GHAPIOrganizationV3 organizationsOfUser:self.username page:1 
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                       [tableView cancelDownloadInSection:section];
                                   } else {
                                       self.organizations = array;
                                       [self setNextPage:nextPage forSection:section];
                                       [tableView expandSection:section animated:YES];
                                       
                                       if ([self.organizations count] == 0) {
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organizations", @"") 
                                                                                            message:[NSString stringWithFormat:NSLocalizedString(@"%@ is not a part of any Organization.", @""), self.username]
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                  otherButtonTitles:nil];
                                           [alert show];
                                       }
                                   }
                               }];
    } else if (section == kUITableViewGists) {
        [GHAPIUserV3 gistsOfUser:self.username 
                            page:1 
               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                   if (error) {
                       [self handleError:error];
                       [tableView cancelDownloadInSection:section];
                   } else {
                       self.gists = array;
                       [self setNextPage:nextPage forSection:section];
                       [self cacheGistsHeight];
                       [tableView expandSection:section animated:YES];
                   }
               }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.user) {
        return 0;
    }
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = 0;
    
    if (section == kUITableViewSectionUserData) {
        result = 1;
    } else if (section == kUITableViewSectionEMail) {
        if (self.user.hasEMail) {
            return 1;
        }
    } else if (section == kUITableViewSectionLocation) {
        if (self.user.hasLocation) {
            return 1;
        }
    } else if (section == kUITableViewSectionCompany) {
        if (self.user.hasCompany) {
            return 1;
        }
    } else if (section == kUITableViewSectionBlog) {
        if (self.user.hasBlog) {
            return 1;
        }
    } else if (section == kUITableViewSectionPublicActivity) {
        return 1;
    } else if (section == kUITableViewSectionRepositories) {
        result = [self.repositoriesArray count] + 1;
    } else if (section == kUITableViewSectionWatchedRepositories) {
        // watched
        result = [self.watchedRepositoriesArray count] + 1;
    } else if (section == kUITableViewSectionPlan && self.user.plan.name) {
        result = 5;
    } else if (section == kUITableViewFollowingUsers) {
        if (self.user.following == 0) {
            return 0;
        }
        return [self.followingUsers count] + 1;
    } else if (section == kUITableViewFollowedUsers) {
        if (self.user.followers == 0) {
            return 0;
        }
        return [self.followedUsers count] + 1;
    } else if (section == kUITableViewOrganizations) {
        return [self.organizations count] + 1;
    } else if (section == kUITableViewGists) {
        return self.gists.count + 1;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"TitleTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = self.user.login;
            cell.descriptionLabel.text = nil;
            cell.detailTextLabel.text = nil;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.user.avatarURL];
            
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
            cell.detailTextLabel.text = self.user.EMail;
            
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
            cell.detailTextLabel.text = self.user.location;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionCompany) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = NSLocalizedString(@"Company", @"");
            cell.detailTextLabel.text = self.user.company;
            
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
            cell.detailTextLabel.text = self.user.blog;
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
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        // display all repostories
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIRepositoryV3 *repository = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner.login, repository.name];
        cell.descriptionLabel.text = repository.description;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        // watched repositories
        if (indexPath.row <= [self.watchedRepositoriesArray count] ) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            GHAPIRepositoryV3 *repository = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner.login, repository.name];
            
            cell.descriptionLabel.text = repository.description;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPlan) {
        NSString *CellIdentifier = @"DetailsTableViewCell";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Type", @"");
            cell.detailTextLabel.text = self.user.plan.name;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Private Repos", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.user.plan.privateRepos];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Collaborators", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.user.plan.collaborators];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Space", @"");
            cell.detailTextLabel.text = [[NSString stringFormFileSize:[self.user.plan.space longLongValue] ] stringByAppendingFormat:NSLocalizedString(@" used", @"")];
        } else {
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
        }
        return cell;
    } else if (indexPath.section == kUITableViewFollowingUsers) {
        static NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        GHAPIUserV3 *user = [self.followingUsers objectAtIndex:indexPath.row - 1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewFollowedUsers) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        GHAPIUserV3 *user = [self.followedUsers objectAtIndex:indexPath.row - 1];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewOrganizations) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = organization.name ? organization.name : organization.login;
        
        cell.descriptionLabel.text = organization.type;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:organization.avatarURL];
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == kUITableViewGists) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row-1];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Gist: %@", gist.ID];
        
        cell.descriptionLabel.text = gist.description;
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created %@ ago", @""), gist.createdAt.prettyTimeIntervalSinceNow];
        
        if ([gist.public boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHClipBoard.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHClipBoardPrivate.png"];
        }
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionBlog && indexPath.row == 0) {
        NSURL *URL = [NSURL URLWithString:self.user.blog];
        GHWebViewViewController *web = [[GHWebViewViewController alloc] initWithURL:URL];
        [self.navigationController pushViewController:web animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicActivity && indexPath.row == 0) {
        GHRecentActivityViewController *recentViewController = [[GHRecentActivityViewController alloc] initWithUsername:self.username];
        [self.navigationController pushViewController:recentViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        GHAPIRepositoryV3 *repo = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        GHRepositoryViewController *viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name] ];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        GHAPIRepositoryV3 *repo = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
        
        GHRepositoryViewController *viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name] ];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == kUITableViewFollowingUsers) {
        GHAPIUserV3 *user = [self.followingUsers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewFollowedUsers) {
        GHAPIUserV3 *user = [self.followedUsers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewOrganizations) {
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row - 1];
        GHOrganizationViewController *organizationViewController = [[GHOrganizationViewController alloc] initWithOrganizationLogin:organization.login];
        
        [self.navigationController pushViewController:organizationViewController animated:YES];
    } else if (indexPath.section == kUITableViewGists) {
        GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row - 1];
        
        GHGistViewController *gistViewController = [[GHGistViewController alloc] initWithID:gist.ID];
        [self.navigationController pushViewController:gistViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData && indexPath.row == 0) {
        return 71.0f;
    }
    if (indexPath.section == kUITableViewOrganizations) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        return 71.0;
    }
    if (indexPath.section == kUITableViewSectionRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        // watched repo
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewGists) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

#pragma mark - GHCreateRepositoryViewControllerDelegate

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHAPIRepositoryV3 *)repository {
    [self dismissModalViewControllerAnimated:YES];
    [self.repositoriesArray addObject:repository];
    
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Repository", @"") 
                                                                     message:repository.name];
    
    [self cacheHeightForTableView];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionRepositories] 
                  withRowAnimation:kUITableViewSectionRepositories];
}

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHRepositoryViewController *)singleRepositoryViewController {
    
    NSArray *oldArray = self.lastIndexPathForSingleRepositoryViewController.section == kUITableViewSectionRepositories ? self.repositoriesArray : self.watchedRepositoriesArray;
    NSUInteger index = self.lastIndexPathForSingleRepositoryViewController.row-1;
    
    NSMutableArray *array = [oldArray mutableCopy];
    [array removeObjectAtIndex:index];

    if (self.lastIndexPathForSingleRepositoryViewController.section == kUITableViewSectionRepositories) {
        self.repositoriesArray = array;
    } else {
        self.watchedRepositoriesArray = array;
    }
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.lastIndexPathForSingleRepositoryViewController] 
                          withRowAnimation:UITableViewRowAnimationTop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_repositoriesArray forKey:@"repositoriesArray"];
    [encoder encodeObject:_watchedRepositoriesArray forKey:@"watchedRepositoriesArray"];
    [encoder encodeObject:_followingUsers forKey:@"followingUsers"];
    [encoder encodeObject:_organizations forKey:@"organizations"];
    [encoder encodeObject:_followedUsers forKey:@"followedUsers"];
    [encoder encodeObject:_gists forKey:@"gists"];
    [encoder encodeBool:_hasFollowingData forKey:@"hasFollowingData"];
    [encoder encodeBool:_isFollowingUser forKey:@"isFollowingUser"];
    [encoder encodeObject:_lastIndexPathForSingleRepositoryViewController forKey:@"lastIndexPathForSingleRepositoryViewController"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _username = [decoder decodeObjectForKey:@"username"];
        _user = [decoder decodeObjectForKey:@"user"];
        _repositoriesArray = [decoder decodeObjectForKey:@"repositoriesArray"];
        _watchedRepositoriesArray = [decoder decodeObjectForKey:@"watchedRepositoriesArray"];
        _followingUsers = [decoder decodeObjectForKey:@"followingUsers"];
        _organizations = [decoder decodeObjectForKey:@"organizations"];
        _followedUsers = [decoder decodeObjectForKey:@"followedUsers"];
        _gists = [decoder decodeObjectForKey:@"gists"];
        _hasFollowingData = [decoder decodeBoolForKey:@"hasFollowingData"];
        _isFollowingUser = [decoder decodeBoolForKey:@"isFollowingUser"];
        _lastIndexPathForSingleRepositoryViewController = [decoder decodeObjectForKey:@"lastIndexPathForSingleRepositoryViewController"];
    }
    return self;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionButtonActionSheetTag) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Unfollow", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIUserV3 unfollowUser:self.username 
                    completionHandler:^(NSError *error) {
                        self.actionButtonActive = NO;
                        if (error) {
                            [self handleError:error];
                        } else {
                            _isFollowingUser = NO;
                            [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Stopped following", @"") message:self.username];
                        }
                    }];
        } else if ([title isEqualToString:NSLocalizedString(@"Follow", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIUserV3 followUser:self.username 
                  completionHandler:^(NSError *error) {
                      self.actionButtonActive = NO;
                      if (error) {
                          [self handleError:error];
                      } else {
                          _isFollowingUser = YES;
                          
                          NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                          [self.tableView collapseSection:kUITableViewFollowedUsers animated:YES];
                          self.followedUsers = nil;
                          [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                          [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Now following", @"") message:self.username];
                      }
                  }];
        } else if ([title isEqualToString:NSLocalizedString(@"Create Repository", @"")]) {
            GHCreateRepositoryViewController *createViewController = [[GHCreateRepositoryViewController alloc] init];
            createViewController.delegate = self;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:createViewController];
            [self presentModalViewController:navController animated:YES];
        } else if ([title isEqualToString:NSLocalizedString(@"E-Mail", @"")]) {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:[NSArray arrayWithObject:self.user.EMail]];
            
            [self presentViewController:mailViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    [GHAPIUserV3 isFollowingUserNamed:self.username 
                    completionHandler:^(BOOL following, NSError *error) {
                        if (error) {
                            [self failedToDownloadDataToDisplayActionButtonWithError:error];
                        } else {
                            _hasFollowingData = YES;
                            _isFollowingUser = following;
                            [self didDownloadDataToDisplayActionButton];
                        }
                    }];
}

- (UIActionSheet *)actionButtonActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.username;
    NSUInteger currentButtonIndex = 0;
    
    if (self.canFollowUser) {
        if (_isFollowingUser) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Unfollow", @"")];
            currentButtonIndex++;
        } else {
            [sheet addButtonWithTitle:NSLocalizedString(@"Follow", @"")];
            currentButtonIndex++;
        }
    } else {
        [sheet addButtonWithTitle:NSLocalizedString(@"Create Repository", @"")];
        currentButtonIndex++;
    }
    
    if (self.user.hasEMail && [MFMailComposeViewController canSendMail]) {
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
    if (self.canFollowUser) {
        return !_hasFollowingData;
    }
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
