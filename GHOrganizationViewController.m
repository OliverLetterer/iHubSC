//
//  GHOrganizationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOrganizationViewController.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHWebViewViewController.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHSingleRepositoryViewController.h"
#import "GHUserViewController.h"
#import "GHTeamViewController.h"
#import "GHRecentActivityViewController.h"

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
    [_organizationLogin release];
    _organizationLogin = [organizationLogin copy];
    
    [GHOrganization organizationsNamed:_organizationLogin completionHandler:^(GHOrganization *organization, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.organization = organization;
            [self.tableView reloadData];
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

#pragma mark - Memory management

- (void)dealloc {
    [_organizationLogin release];
    [_organization release];
    [_publicRepositories release];
    [_publicMembers release];
    [_teams release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
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

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionPublicRepositories) {
        [self.organization publicRepositoriesWithCompletionHandler:^(NSArray *repositories, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                self.publicRepositories = repositories;
                [tableView expandSection:section animated:YES];
            }
        }];
    } else if (section == kUITableViewSectionPublicMembers) {
        [self.organization publicMembersWithCompletionHandler:^(NSArray *members, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                self.publicMembers = members;
                [tableView expandSection:section animated:YES];
            }
        }];
    } else if (section == kUITableViewSectionTeams) {
        [self.organization teamsWithCompletionHandler:^(NSArray *teams, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                self.teams = [[teams mutableCopy] autorelease];
                [tableView expandSection:section animated:YES];
                
                if (self.teams.count == 0) {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Teams", @"") 
                                                                     message:NSLocalizedString(@"There are no Teams available for this Organization", @"")
                                                                    delegate:nil 
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                           otherButtonTitles:nil]
                                          autorelease];
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
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellEditingStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.titleLabel.text = self.organization.login;
            cell.descriptionLabel.text = nil;
            cell.repositoryLabel.text = nil;
            
            [self updateImageViewForCell:cell atIndexPath:indexPath withGravatarID:self.organization.gravatarID];
            
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
            cell.detailTextLabel.text = self.organization.EMail;
            
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
            cell.detailTextLabel.text = self.organization.location;
            
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
            cell.detailTextLabel.text = self.organization.blog;
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
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHRepository *repository = [self.publicRepositories objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
        
        cell.descriptionLabel.text = repository.desctiptionRepo;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionPublicMembers) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHUser *user = [self.publicMembers objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionTeams) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHTeam *team = [self.teams objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = team.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return self.dummyCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section == kUITableViewSectionTeams && indexPath.row > 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        GHTeam *team = [[[self.teams objectAtIndex:indexPath.row - 1] retain] autorelease];
        
        [team deleteWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [self.teams removeObjectAtIndex:indexPath.row - 1];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
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
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return 71.0f;
        }
        return 44.0f;
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        return 71.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionBlog && indexPath.row == 0) {
        NSURL *URL = [NSURL URLWithString:self.organization.blog];
        GHWebViewViewController *web = [[[GHWebViewViewController alloc] initWithURL:URL] autorelease];
        [self.navigationController pushViewController:web animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicActivity && indexPath.row == 0) {
        GHRecentActivityViewController *recentViewController = [[[GHRecentActivityViewController alloc] initWithUsername:self.organization.login] autorelease];
        [self.navigationController pushViewController:recentViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicRepositories) {
        GHRepository *repo = [self.publicRepositories objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionPublicMembers) {
        GHUser *user = [self.publicMembers objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionTeams) {
        GHTeam *team = [self.teams objectAtIndex:indexPath.row - 1];
        
        GHTeamViewController *teamViewController = [[[GHTeamViewController alloc] initWithTeam:team] autorelease];
        [self.navigationController pushViewController:teamViewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
