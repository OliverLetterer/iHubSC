//
//  GHUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUserViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHSingleRepositoryViewController.h"
#import "GHWebViewViewController.h"
#import "NSString+Additions.h"
#import "GHRecentActivityViewController.h"
#import "GHOrganizationViewController.h"
#import "GHGistViewController.h"
#import "INNotificationQueue.h"

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
#define kUITableViewNetwork                     13

#define kUITableViewNumberOfSections            14

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
    return [self.username isEqualToString:[GHAuthenticationManager sharedInstance].username ];
}

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    self.title = self.username;
    
    self.watchedRepositoriesArray = nil;
    self.repositoriesArray = nil;
    self.user = nil;
    self.followingUsers = nil;
    self.followedUsers = nil;
    
    [self downloadUserData];
    
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.username = username;
        DLog(@"%@", self.username);
        self.pullToReleaseEnabled = self.hasAdministrationRights;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoriesArray release];
    [_username release];
    [_watchedRepositoriesArray release];
    [_followingUsers release];
    [_followedUsers release];
    [_lastIndexPathForSingleRepositoryViewController release];
    [_organizations release];
    [_user release];
    [_gists release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button {
    GHCreateRepositoryViewController *createViewController = [[[GHCreateRepositoryViewController alloc] init] autorelease];
    createViewController.delegate = self;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:createViewController] autorelease];
    [self presentModalViewController:navController animated:YES];
}

- (void)accountButtonClicked:(UIBarButtonItem *)button {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Account", @"") 
                                                     message:[NSString stringWithFormat:NSLocalizedString(@"You are logged in as: %@\nRemaining API calls for today: %d", @""), [GHAuthenticationManager sharedInstance].username, [GHBackgroundQueue sharedInstance].remainingAPICalls ]
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                           otherButtonTitles:NSLocalizedString(@"Logout", @""), nil]
                          autorelease];
    [alert show];
}

#pragma mark - instance methods

- (void)downloadUserData {
    _isDownloadingUserData = YES;
    [GHAPIUserV3 userWithName:self.username 
         completionHandler:^(GHAPIUserV3 *user, NSError *error) {
             _isDownloadingUserData = NO;
             if (error) {
                 [self handleError:error];
             } else {
                 self.user = user;
                 [self.tableView reloadData];
             }
             [self pullToReleaseTableViewDidReloadData];
         }];
}

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
    [self downloadUserData];
}

- (void)cacheHeightForTableView {
    NSInteger i = 0;
    for (GHAPIRepositoryV3 *repo in self.repositoriesArray) {
        CGFloat height = [self heightForDescription:repo.description] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionRepositories]];
        
        i++;
    }
}

- (void)cacheHeightForWatchedRepositories {
    NSInteger i = 0;
    for (GHAPIRepositoryV3 *repo in self.watchedRepositoriesArray) {
        CGFloat height = [self heightForDescription:repo.description] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionWatchedRepositories]];
        
        i++;
    }
}

- (void)cacheGistsHeight {
    [self.gists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        
        CGFloat height = [self heightForDescription:gist.description] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewGists]];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hasAdministrationRights) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                                target:self 
                                                                                                action:@selector(createRepositoryButtonClicked:)]
                                                  autorelease];
    }
    
    if ([[self.navigationController viewControllers] objectAtIndex:0] == self && self.hasAdministrationRights) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", @"") 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self action:@selector(accountButtonClicked:)]
                                                 autorelease];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionRepositories || 
            section == kUITableViewSectionWatchedRepositories || 
            section == kUITableViewSectionPlan ||
            section == kUITableViewFollowingUsers ||
            section == kUITableViewFollowedUsers ||
            section == kUITableViewNetwork || 
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
    } else if (section == kUITableViewNetwork) {
        return !_hasFollowingData;
    } else if (section == kUITableViewOrganizations) {
        return self.organizations == nil;
    } else if (section == kUITableViewGists) {
        return self.gists == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
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
    } else if (section == kUITableViewNetwork) {
        cell.textLabel.text = NSLocalizedString(@"Network", @"");
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
    } else if (section == kUITableViewNetwork) {
        [GHAPIUserV3 isFollowingUserNamed:self.username 
                     completionHandler:^(BOOL following, NSError *error) {
                         if (error) {
                             [self handleError:error];
                             [tableView cancelDownloadInSection:section];
                         } else {
                             _hasFollowingData = YES;
                             _isFollowingUser = following;
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
                                           UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organizations", @"") 
                                                                                            message:[NSString stringWithFormat:NSLocalizedString(@"%@ is not a part of any Organization.", @""), self.username]
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                  otherButtonTitles:nil]
                                                                 autorelease];
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
    if (_isDownloadingUserData || !self.user) {
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
    } else if (section == kUITableViewNetwork) {
        if (!self.canFollowUser) {
            return 0;
        } else {
            return 2;
        }
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
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.titleLabel.text = self.user.login;
            cell.descriptionLabel.text = nil;
            cell.repositoryLabel.text = nil;
            
            [self updateImageViewForCell:cell atIndexPath:indexPath withGravatarID:self.user.gravatarID];
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionEMail) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIRepositoryV3 *repository = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner.login, repository.name];
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
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIRepositoryV3 *repository = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner.login, repository.name];
            
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
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHAPIUserV3 *user = [self.followingUsers objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewFollowedUsers) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHAPIUserV3 *user = [self.followedUsers objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewNetwork) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundViewNetwork2";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = _isFollowingUser ? NSLocalizedString(@"Unfollow", @"") : NSLocalizedString(@"Follow", @"");
        
        return cell;
    } else if (indexPath.section == kUITableViewOrganizations) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = organization.name ? organization.name : organization.login;
        
        cell.descriptionLabel.text = organization.type;
        
        [self updateImageViewForCell:cell atIndexPath:indexPath withGravatarID:organization.gravatarID];
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == kUITableViewGists) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"Gist: %@", gist.ID];
        
        cell.descriptionLabel.text = gist.description;
        cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created %@ ago", @""), gist.createdAt.prettyTimeIntervalSinceNow];
        
        if ([gist.public boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHClipBoard.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHClipBoardPrivate.png"];
        }
        
        return cell;
    }
    
    return self.dummyCell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == kUITableViewGists && indexPath.row > 0 && self.hasAdministrationRights) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (indexPath.section == kUITableViewGists && indexPath.row > 0) {
            GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row - 1];
            
            [GHAPIGistV3 deleteGistWithID:gist.ID completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] 
                             withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [self.gists removeObjectAtIndex:indexPath.row - 1];
                    [self cacheGistsHeight];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionBlog && indexPath.row == 0) {
        NSURL *URL = [NSURL URLWithString:self.user.blog];
        GHWebViewViewController *web = [[[GHWebViewViewController alloc] initWithURL:URL] autorelease];
        [self.navigationController pushViewController:web animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicActivity && indexPath.row == 0) {
        GHRecentActivityViewController *recentViewController = [[[GHRecentActivityViewController alloc] initWithUsername:self.username] autorelease];
        [self.navigationController pushViewController:recentViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        GHAPIRepositoryV3 *repo = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        GHAPIRepositoryV3 *repo = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner.login, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == kUITableViewFollowingUsers) {
        GHAPIUserV3 *user = [self.followingUsers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewFollowedUsers) {
        GHAPIUserV3 *user = [self.followedUsers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewNetwork) {
        if (_isFollowingUser) {
            [GHAPIUserV3 unfollowUser:self.username 
                 completionHandler:^(NSError *error) {
                     if (error) {
                         [self handleError:error];
                     } else {
                         _isFollowingUser = NO;
                         
                         NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                         [set addIndex:kUITableViewNetwork];
                         [self.tableView collapseSection:kUITableViewFollowedUsers animated:YES];
                         self.followedUsers = nil;
                         [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                         [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Stopped following", @"") andSubtitle:self.username removeStyle:INNotificationQueueItemRemoveByFadingOut];
                     }
                 }];
        } else {
            [GHAPIUserV3 followUser:self.username 
               completionHandler:^(NSError *error) {
                   if (error) {
                       [self handleError:error];
                   } else {
                       _isFollowingUser = YES;
                       
                       NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                       [set addIndex:kUITableViewNetwork];
                       [self.tableView collapseSection:kUITableViewFollowedUsers animated:YES];
                       self.followedUsers = nil;
                       [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                       [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Now following", @"") andSubtitle:self.username removeStyle:INNotificationQueueItemRemoveByFadingOut];
                   }
               }];
        }
    } else if (indexPath.section == kUITableViewOrganizations) {
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row - 1];
        GHOrganizationViewController *organizationViewController = [[[GHOrganizationViewController alloc] initWithOrganizationLogin:organization.login] autorelease];
        
        [self.navigationController pushViewController:organizationViewController animated:YES];
    } else if (indexPath.section == kUITableViewGists) {
        GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row - 1];
        
        GHGistViewController *gistViewController = [[[GHGistViewController alloc] initWithID:gist.ID] autorelease];
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
    
    [self cacheHeightForTableView];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionRepositories] 
                  withRowAnimation:kUITableViewSectionRepositories];
}

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController {
    
    NSArray *oldArray = self.lastIndexPathForSingleRepositoryViewController.section == kUITableViewSectionRepositories ? self.repositoriesArray : self.watchedRepositoriesArray;
    NSUInteger index = self.lastIndexPathForSingleRepositoryViewController.row-1;
    
    NSMutableArray *array = [[oldArray mutableCopy] autorelease];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Logout clicked
        [self invalidadUserData];
        [self handleError:[NSError errorWithDomain:@"" code:3 userInfo:nil] ];
    }
}

@end
