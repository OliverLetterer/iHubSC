//
//  GHPUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPUserViewController.h"
#import "GHPOwnedRepositoriesOfUserViewController.h"
#import "GHPWatchedRepositoriesViewController.h"
#import "GHPFollwingUsersViewController.h"
#import "GHPFollowedUsersViewController.h"
#import "GHPGistsOfUserViewController.h"
#import "GHPUsersNewsFeedViewController.h"
#import "GHPOrganizationsOfUserViewController.h"
#import "GHPIssuesOfAuthenticatedUserViewController.h"

#import "GHSettingsHelper.h"
#import "ANNotificationQueue.h"

#define kUITableViewSectionUserInfo         0
#define kUITableViewSectionUserContent      1
#define kUITableViewSectionAUContent        2

#define kUITableViewNumberOfSections        3

@implementation GHPUserViewController

@synthesize user=_user, username=_username;

#pragma mark - setters and getters

- (BOOL)isAdminsitrativeUser {
    return [[GHAuthenticationManager sharedInstance].username isEqualToString:self.username];
}

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIUserV3 userWithName:_username 
            completionHandler:^(GHAPIUserV3 *user, NSError *error) {
                self.isDownloadingEssentialData = NO;
                if (error) {
                    [self handleError:error];
                } else {
                    self.user = user;
                    if (self.isViewLoaded) {
                        [self.tableView reloadData];
                    }
                }
            }];
}

- (NSString *)userDetailInfoString {
    NSMutableString *string = [NSMutableString stringWithCapacity:500];
    
    [string appendFormat:NSLocalizedString(@"Member since: %@\n", @""), self.user.createdAt.prettyTimeIntervalSinceNow];
    [string appendFormat:NSLocalizedString(@"Repositories: %d\n", @""), self.user.publicRepos.intValue + self.user.totalPrivateRepos.intValue];
    [string appendFormat:NSLocalizedString(@"Followers: %@\n", @""), self.user.followers];
    if (self.user.hasEMail) {
        [string appendFormat:NSLocalizedString(@"E-Mail: %@\n", @""), self.user.EMail];
    }
    if (self.user.hasLocation) {
        [string appendFormat:NSLocalizedString(@"Location: %@\n", @""), self.user.location];
    }
    if (self.user.hasCompany) {
        [string appendFormat:NSLocalizedString(@"Company: %@\n", @""), self.user.company];
    }
    
    return string;
}

#pragma mark - initialization

- (id)initWithUsername:(NSString *)username {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - memory management

- (void)dealloc {
    [_user release];
    [_username release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.user) {
        return 0;
    }
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionUserContent) {
        return 7;
    } else if (section == kUITableViewSectionUserInfo) {
        return 1;
    } else if (section == kUITableViewSectionAUContent) {
        if ([self.username isEqualToString:[GHAuthenticationManager sharedInstance].username]) {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserContent) {
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Watched Repositories", @"");
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Following", @"");
        } else if (indexPath.row == 3) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User following %@", @""), self.user.login];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Gists", @"");
        } else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Organizations", @"");
        } else if (indexPath.row == 6) {
            cell.textLabel.text = NSLocalizedString(@"Public Activity", @"");
        } else {
            cell.textLabel.text = nil;
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionUserInfo) {
        if (indexPath.row == 0) {
            GHPInfoTableViewCell *cell = self.infoCell;
            
            cell.textLabel.text = self.user.login;
            cell.detailTextLabel.text = self.userDetailInfoString;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.user.avatarURL];
            
            if (!self.canDisplayActionButton) {
                [cell.actionButton removeFromSuperview];
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAUContent) {
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Issues assigned to me", @"");
        } else {
            cell.textLabel.text = nil;
        }
        
        return cell;
    }

    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserInfo) {
        return [GHPInfoTableViewCell heightWithContent:self.userDetailInfoString];
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionUserContent) {
        if (indexPath.row == 0) {
            // Repositories
            viewController = [[[GHPOwnedRepositoriesOfUserViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPWatchedRepositoriesViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 2) {
            viewController = [[[GHPFollwingUsersViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 3) {
            viewController = [[[GHPFollowedUsersViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 4) {
            viewController = [[[GHPGistsOfUserViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 6) {
            viewController = [[[GHPUsersNewsFeedViewController alloc] initWithUsername:self.username] autorelease];
        } else if (indexPath.row == 5) {
            viewController = [[[GHPOrganizationsOfUserViewController alloc] initWithUsername:self.username] autorelease];
        }
    } else if (indexPath.section == kUITableViewSectionAUContent) {
        if (indexPath.row == 0) {
            viewController = [[[GHPIssuesOfAuthenticatedUserViewController alloc] initWithUsername:self.username] autorelease];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = nil;
    @try {
        title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    @catch (NSException *exception) { }
    
    if ([title isEqualToString:NSLocalizedString(@"Follow", @"")]) {
        [self setActionButtonActive:YES];
        [GHAPIUserV3 followUser:self.username 
              completionHandler:^(NSError *error) {
                  [self setActionButtonActive:NO];
                  if (error) {
                      [self handleError:error];
                  } else {
                      [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Now following", @"") message:self.username];
                      _isFollowingUser = YES;
                  }
              }];
    } else if ([title isEqualToString:NSLocalizedString(@"Unfollow", @"")]) {
        [self setActionButtonActive:YES];
        [GHAPIUserV3 unfollowUser:self.username 
              completionHandler:^(NSError *error) {
                  [self setActionButtonActive:NO];
                  if (error) {
                      [self handleError:error];
                  } else {
                      [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Stopped following", @"") message:self.username];
                      _isFollowingUser = NO;
                  }
              }];
    } else if ([title isEqualToString:NSLocalizedString(@"View Blog in Safari", @"")]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.user.blog] ];
    } else if ([title isEqualToString:NSLocalizedString(@"E-Mail", @"")]) {
        MFMailComposeViewController *mailViewController = [[[MFMailComposeViewController alloc] init] autorelease];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:self.user.EMail]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ActionMenu

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
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    if (!self.isAdminsitrativeUser) {
        if (!_isFollowingUser) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Follow", @"")];
        } else {
            [sheet addButtonWithTitle:NSLocalizedString(@"Unfollow", @"")];
        }
    }
    
    if (self.user.hasBlog) {
        [sheet addButtonWithTitle:NSLocalizedString(@"View Blog in Safari", @"")];
    }
    if (self.user.hasEMail && [MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"E-Mail", @"")];
    }
    
    if (sheet.numberOfButtons == 0) {
        return nil;
    }
    sheet.delegate = self;
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return !self.isAdminsitrativeUser;
}

- (BOOL)canDisplayActionButtonActionSheet {
    return _hasFollowingData;
}


@end
