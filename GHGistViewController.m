//
//  GHGistViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGistViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "NSString+Additions.h"
#import "GHUserViewController.h"
#import "GHViewCloudFileViewController.h"

#define kUITableViewSectionInfo 0
#define kUITableViewSectionFiles 1
#define kUITableViewSectionForks 2
#define kUITableViewSectionStar 3

#define kUITableViewSections 4

@implementation GHGistViewController

@synthesize ID=_ID, gist=_gist;

#pragma mark - setters and getters

- (void)setID:(NSString *)ID {
    [_ID release];
    _ID = [ID copy];
    
    [GHGist gistWithID:_ID completionHandler:^(GHGist *gist, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.gist = gist;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Initialization

- (id)initWithID:(NSString *)ID {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.ID = ID;
        self.title = NSLocalizedString(@"Gist", @"");
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_gist release];
    
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
    return section == kUITableViewSectionFiles || section == kUITableViewSectionForks || section == kUITableViewSectionStar;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionStar) {
        return !_hasStarData;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
    if (section == kUITableViewSectionFiles) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Files (%d)", @""), self.gist.files.count ];
    } else if (section == kUITableViewSectionForks) {
        cell.textLabel.text = NSLocalizedString(@"Forked by", @"");
    } else if (section == kUITableViewSectionStar) {
        if (!_hasStarData) {
            cell.textLabel.text = NSLocalizedString(@"Star", @"");
        } else {
            if (_isGistStarred) {
                cell.textLabel.text = NSLocalizedString(@"Starred", @"");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Unstarred", @"");
            }
        }
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionStar) {
        [GHGist isGistStarredWithID:self.gist.ID completionHandler:^(BOOL starred, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                _hasStarData = YES;
                _isGistStarred = starred;
                [tableView expandSection:section animated:YES];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if (!self.gist) {
        return 0;
    }
    
    // gist itself
    return kUITableViewSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionInfo) {
        return 1;
    } else if (section == kUITableViewSectionFiles) {
        return self.gist.files.count + 1;
    } else if (section == kUITableViewSectionForks) {
        return self.gist.forks.count + 1;
    } else if (section == kUITableViewSectionStar) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHGist *gist = self.gist;
            
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
    } else if (indexPath.section == kUITableViewSectionFiles) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        GHGistFile *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = file.filename;
        cell.detailTextLabel.text = [NSString stringFormFileSize:[file.size longLongValue] ];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionForks) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHGistFork *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = fork.user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionStar) {
        if (indexPath.row == 1) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundViewStar";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = _isGistStarred ? NSLocalizedString(@"Unstar", @"") : NSLocalizedString(@"Star", @"");
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            CGFloat height = [self heightForDescription:self.gist.description] + 50.0;
            
            if (height < 71.0) {
                height = 71.0;
            }
            
            return height;
        }
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionForks) {
        GHGistFork *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:fork.user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionFiles) {
        GHGistFile *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        GHViewCloudFileViewController *fileViewController = [[[GHViewCloudFileViewController alloc] initWithFile:file.filename contentsOfFile:file.content] autorelease];
        [self.navigationController pushViewController:fileViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionStar && indexPath.row == 1) {
        if (_isGistStarred) {
            [GHGist unstarGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = NO;
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionStar] 
                         withRowAnimation:UITableViewRowAnimationNone];
            }];
        } else {
            [GHGist starGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = YES;
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionStar] 
                         withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
