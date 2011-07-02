//
//  GHPUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPUserViewController.h"
#import "GHPUserInfoTableViewCell.h"
#import "GHSettingsHelper.h"
#import "GHPOwnedRepositoriesOfUserViewController.h"
#import "GHPWatchedRepositoriesViewController.h"

#define kUITableViewSectionUserInfo         0
#define kUITableViewSectionUserContent      1

#define kUITableViewNumberOfSections        2

@implementation GHPUserViewController

@synthesize user=_user, username=_username, userInfoCell=_userInfoCell;

#pragma mark - setters and getters

- (BOOL)isAdminsitrativeUser {
    return [[GHAuthenticationManager sharedInstance].username isEqualToString:self.username];
}

- (BOOL)canDisplayActionButton {
    NSUInteger numberOfButtons = 0;
    if (!self.isAdminsitrativeUser) {
        numberOfButtons++;
    }
    
    if (self.user.hasBlog) {
        numberOfButtons++;
    }
    if (self.user.hasEMail && [MFMailComposeViewController canSendMail]) {
        numberOfButtons++;
    }
    return numberOfButtons > 0;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_userInfoCell release], _userInfoCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
            NSString *CellIdentifier = @"GHPUserInfoTableViewCell";
            GHPUserInfoTableViewCell *cell = (GHPUserInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHPUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                        reuseIdentifier:CellIdentifier]
                        autorelease];
            }
            
            cell.textLabel.text = self.user.login;
            cell.detailTextLabel.text = self.userDetailInfoString;
            
            NSString *gravatarID = self.user.gravatarID;
            UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:gravatarID];
            
            if (gravatarImage) {
                cell.imageView.image = gravatarImage;
            } else {
                [UIImage imageFromGravatarID:gravatarID 
                       withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                           [self.tableView reloadData];
                       }];
            }
            
            if (!self.canDisplayActionButton) {
                [cell.actionButton removeFromSuperview];
            }
            cell.delegate = self;
            
            self.userInfoCell = cell;
            
            return cell;
        }
    }

    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserInfo) {
        CGSize size = [self.userDetailInfoString sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                            constrainedToSize:CGSizeMake(349.0f, CGFLOAT_MAX) 
                                                lineBreakMode:UILineBreakModeWordWrap];
        return size.height + 29.0f;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserContent) {
        if (indexPath.row == 0) {
            // Repositories
            GHPOwnedRepositoriesOfUserViewController *repoViewController = [[[GHPOwnedRepositoriesOfUserViewController alloc] initWithUsername:self.username] autorelease];
            [self.advancedNavigationController pushViewController:repoViewController afterViewController:self];
        } else if (indexPath.row == 1) {
            GHPWatchedRepositoriesViewController *repoViewController = [[[GHPWatchedRepositoriesViewController alloc] initWithUsername:self.username] autorelease];
            [self.advancedNavigationController pushViewController:repoViewController afterViewController:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - memory management

- (void)dealloc {
    [_user release];
    [_username release];
    [_userInfoCell release];
    
    [super dealloc];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = nil;
    @try {
        title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
    @catch (NSException *exception) { }
    
    if ([title isEqualToString:NSLocalizedString(@"Follow", @"")]) {
        self.userInfoCell.actionButton.alpha = 0.0f;
        [self.userInfoCell.activityIndicatorView startAnimating];
        [GHAPIUserV3 followUser:self.username 
              completionHandler:^(NSError *error) {
                  self.userInfoCell.actionButton.alpha = 1.0f;
                  [self.userInfoCell.activityIndicatorView stopAnimating];
                  if (error) {
                      [self handleError:error];
                  } else {
                      [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Now following", @"") andSubtitle:self.username removeStyle:INNotificationQueueItemRemoveByFadingOut];
                      _isFollowingUser = YES;
                  }
              }];
    } else if ([title isEqualToString:NSLocalizedString(@"Unfollow", @"")]) {
        self.userInfoCell.actionButton.alpha = 0.0f;
        [self.userInfoCell.activityIndicatorView startAnimating];
        [GHAPIUserV3 unfollowUser:self.username 
              completionHandler:^(NSError *error) {
                  self.userInfoCell.actionButton.alpha = 1.0f;
                  [self.userInfoCell.activityIndicatorView stopAnimating];
                  if (error) {
                      [self handleError:error];
                  } else {
                      [[INNotificationQueue sharedQueue] detachSmallNotificationWithTitle:NSLocalizedString(@"Stopped following", @"") andSubtitle:self.username removeStyle:INNotificationQueueItemRemoveByFadingOut];
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

#pragma mark - GHPUserInfoTableViewCellDelegate

- (void)userInfoTableViewCellActionButtonClicked:(GHPUserInfoTableViewCell *)cell {
    if (!self.isAdminsitrativeUser && !_hasFollowingData) {
        cell.actionButton.alpha = 0.0f;
        [cell.activityIndicatorView startAnimating];
        [GHAPIUserV3 isFollowingUserNamed:self.username 
                        completionHandler:^(BOOL following, NSError *error) {
                            cell.actionButton.alpha = 1.0f;
                            [cell.activityIndicatorView stopAnimating];
                            if (error) {
                                [self handleError:error];
                            } else {
                                _hasFollowingData = YES;
                                _isFollowingUser = following;
                                UIActionSheet *sheet = self.actionButtonActionSheet;
                                
                                [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                                             inView:self.view 
                                           animated:YES];
                            }
                        }];
    } else {
        UIActionSheet *sheet = self.actionButtonActionSheet;
        
        [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                     inView:self.view 
                   animated:YES];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
