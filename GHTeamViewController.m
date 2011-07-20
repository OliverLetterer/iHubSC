//
//  GHTeamViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTeamViewController.h"
#import "GithubAPI.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHUserViewController.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"

#define kUITableViewSectionMembers 0
#define kUITableViewSectionRepositories 1

@implementation GHTeamViewController

@synthesize team=_team, teamID=_teamID, members=_members, repositories=_repositories;

- (void)setTeamID:(NSNumber *)teamID {
    [_teamID release];
    _teamID = [teamID copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPITeamV3 teamByID:_teamID 
        completionHandler:^(GHAPITeamV3 *team, NSError *error) {
            self.isDownloadingEssentialData = NO;
            if (error) {
                [self handleError:error];
            } else {
                self.team = team;
                self.title = self.team.name;
                if (self.isViewLoaded) {
                    [self.tableView reloadData];
                }
            }
        }];
}

#pragma mark - Initialization

- (id)initWithTeamID:(NSNumber *)teamID {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.teamID = teamID;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_team release];
    [_teamID release];
    [_members release];
    [_repositories release];
    
    [super dealloc];
}

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
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionMembers) {
        return self.members.count + 1;
    } else if (section == kUITableViewSectionRepositories) {
        return self.repositories.count + 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionMembers) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHAPIUserV3 *user = [self.members objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIRepositoryV3 *repository = [self.repositories objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = repository.name;
        cell.descriptionLabel.text = repository.description;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        return cell;
    }
    
    return self.dummyCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == kUITableViewSectionMembers && indexPath.row > 0) {
        return YES;
    } else if (indexPath.section == kUITableViewSectionRepositories && indexPath.row > 0) {
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (indexPath.section == kUITableViewSectionMembers) {
            GHAPIUserV3 *user = [self.members objectAtIndex:indexPath.row - 1];
            
            [GHAPITeamV3 teamByID:self.teamID deleteUserNamed:user.login completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [self.members removeObjectAtIndex:indexPath.row - 1];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        } else if (indexPath.section == kUITableViewSectionRepositories) {
            GHAPIRepositoryV3 *repo = [self.repositories objectAtIndex:indexPath.row-1];
            
            NSString *repoName = [NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name];
            
            [GHAPITeamV3 teamByID:self.teamID deleteRepositoryNamed:repoName 
                completionHandler:^(NSError *error) {
                    if (error) {
                        [self handleError:error];
                        [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    } else {
                        [self.repositories removeObjectAtIndex:indexPath.row - 1];
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }];
        }
    }
}

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
    if (indexPath.section == kUITableViewSectionRepositories && indexPath.row > 0) {
        return 71.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionMembers && indexPath.row > 0) {
        GHAPIUserV3 *user = [self.members objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionRepositories && indexPath.row > 0) {
        
        GHRepository *repo = [self.repositories objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_team forKey:@"team"];
    [encoder encodeObject:_teamID forKey:@"teamID"];
    [encoder encodeObject:_members forKey:@"members"];
    [encoder encodeObject:_repositories forKey:@"repositories"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _team = [[decoder decodeObjectForKey:@"team"] retain];
        _teamID = [[decoder decodeObjectForKey:@"teamID"] retain];
        _members = [[decoder decodeObjectForKey:@"members"] retain];
        _repositories = [[decoder decodeObjectForKey:@"repositories"] retain];
    }
    return self;
}

@end
