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

#define kUITableViewSectionUserInfo         0
#define kUITableViewSectionUserContent      1

#define kUITableViewNumberOfSections        2

@implementation GHPUserViewController

@synthesize user=_user, username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    
    [GHAPIUserV3 userWithName:_username 
            completionHandler:^(GHAPIUserV3 *user, NSError *error) {
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
        return 6;
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
        CGSize size = [self.userDetailInfoString sizeWithFont:[UIFont systemFontOfSize:16.0f]
                                            constrainedToSize:CGSizeZero 
                                                lineBreakMode:UILineBreakModeWordWrap];
        return size.height + 64.0f + 20.0f;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - memory management

- (void)dealloc {
    [_user release];
    [_username release];
    
    [super dealloc];
}

@end
