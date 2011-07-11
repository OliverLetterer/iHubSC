//
//  GHPOrganizationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOrganizationViewController.h"
#import "GHPUsersNewsFeedViewController.h"
#import "GHPRepositoriesOfOrganizationViewController.h"
#import "GHPMembersOfOrganizationViewController.h"
#import "GHPTeamsOfOrganizationViewController.h"

#define kUITableViewSectionContent              0

#define kUITableViewNumberOfSections            1

@implementation GHPOrganizationViewController
@synthesize organizationName=_organizationName, organization=_organization;

#pragma mark - setters and getters

- (void)setOrganizationName:(NSString *)organizationName {
    [_organizationName release], _organizationName = [organizationName copy];
    
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

#pragma mark - Initialization

- (id)initWithOrganizationName:(NSString *)organizationName {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.organizationName = organizationName;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_organizationName release];
    [_organization release];
    
    [super dealloc];
}

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
    }
        
    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionContent) {
        if (indexPath.row == 0) {
            viewController = [[[GHPUsersNewsFeedViewController alloc] initWithUsername:self.organizationName] autorelease];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPRepositoriesOfOrganizationViewController alloc] initWithUsername:self.organizationName] autorelease];
        } else if (indexPath.row == 2) {
            viewController = [[[GHPMembersOfOrganizationViewController alloc] initWithUsername:self.organizationName] autorelease];
        } else if (indexPath.row == 3) {
            viewController = [[[GHPTeamsOfOrganizationViewController alloc] initWithOrganizationName:self.organizationName] autorelease];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
