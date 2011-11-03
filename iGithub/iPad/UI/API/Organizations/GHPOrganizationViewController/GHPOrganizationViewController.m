//
//  GHPOrganizationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOrganizationViewController.h"
#import "GHPOrganizationNewsFeedViewController.h"
#import "GHPRepositoriesOfOrganizationViewController.h"
#import "GHPMembersOfOrganizationViewController.h"
#import "GHPTeamsOfOrganizationViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewSectionInfo                 0
#define kUITableViewSectionContent              1

#define kUITableViewNumberOfSections            2

@implementation GHPOrganizationViewController
@synthesize organizationName=_organizationName, organization=_organization;

#pragma mark - setters and getters

- (void)setOrganizationName:(NSString *)organizationName {
    _organizationName = [organizationName copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIOrganizationV3 organizationByName:_organizationName 
                          completionHandler:^(GHAPIOrganizationV3 *organization, NSError *error) {
                              self.isDownloadingEssentialData = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.organization = organization;
                                  
                                  if (self.isViewLoaded) {
                                      [self.tableView reloadData];
                                  }
                              }
                          }];
}

- (NSString *)infoDetailsString {
    NSMutableString *string = [NSMutableString stringWithCapacity:500];
    
    [string appendFormat:NSLocalizedString(@"Since: %@\n", @""), self.organization.createdAt.prettyTimeIntervalSinceNow];
    [string appendFormat:NSLocalizedString(@"Repositories: %d\n", @""), self.organization.publicRepos.intValue];
    if (self.organization.hasEMail) {
        [string appendFormat:NSLocalizedString(@"E-Mail: %@\n", @""), self.organization.EMail];
    }
    if (self.organization.hasLocation) {
        [string appendFormat:NSLocalizedString(@"Location: %@\n", @""), self.organization.location];
    }
    
    return string;
}

#pragma mark - Initialization

- (id)initWithOrganizationName:(NSString *)organizationName {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.organizationName = organizationName;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
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
    if (section == kUITableViewSectionContent) {
        // Public Activity
        // Public Repositories
        // Public Members
        // Public Teams
        return 4;
    } else if (section == kUITableViewSectionInfo) {
        return 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionContent) {
        static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Activity", @"");
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Members", @"");
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Teams", @"");
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionInfo) {
        GHPInfoTableViewCell *cell = self.infoCell;   
        
        cell.textLabel.text = self.organization.login;
        cell.detailTextLabel.text = self.infoDetailsString;
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.organization.avatarURL];
        
        return cell;
    }
        
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return [GHPInfoTableViewCell heightWithContent:self.infoDetailsString];
        }
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionContent) {
        if (indexPath.row == 0) {
            viewController = [[GHPOrganizationNewsFeedViewController alloc] initWithUsername:self.organizationName];
        } else if (indexPath.row == 1) {
            viewController = [[GHPRepositoriesOfOrganizationViewController alloc] initWithUsername:self.organizationName];
        } else if (indexPath.row == 2) {
            viewController = [[GHPMembersOfOrganizationViewController alloc] initWithUsername:self.organizationName];
        } else if (indexPath.row == 3) {
            viewController = [[GHPTeamsOfOrganizationViewController alloc] initWithOrganizationName:self.organizationName];
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
    
    if ([title isEqualToString:NSLocalizedString(@"View Blog in Safari", @"")]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.organization.blog] ];
    } else if ([title isEqualToString:NSLocalizedString(@"E-Mail", @"")]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:self.organization.EMail]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else if ([title isEqualToString:NSLocalizedString(@"Add Team", @"")]) {
        GHCreateTeamViewController *viewController = [[GHCreateTeamViewController alloc] initWithOrganization:self.organizationName];
        viewController.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - GHCreateTeamViewControllerDelegate

- (void)createTeamViewControllerDidCancel:(GHCreateTeamViewController *)createViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTeamViewController:(GHCreateTeamViewController *)createViewController didCreateTeam:(GHAPITeamV3 *)team {
    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Created Team", @"") message:team.name];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

#pragma mark - ActionMenu

- (void)downloadDataToDisplayActionButton {
    [GHAPIOrganizationV3 isUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login administratorInOrganization:self.organizationName completionHandler:^(BOOL state, NSError *error) {
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
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = self.organizationName;
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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_organizationName forKey:@"organizationName"];
    [encoder encodeObject:_organization forKey:@"organization"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _organizationName = [decoder decodeObjectForKey:@"organizationName"];
        _organization = [decoder decodeObjectForKey:@"organization"];
    }
    return self;
}

@end
