//
//  GHPLeftNavigationController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPLeftNavigationController.h"
#import "GHPLeftNavigationControllerTableViewCell.h"
#import "GHPEdgedLineView.h"
#import "GHAuthenticationManager.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "UIImage+Resize.h"

@implementation GHPLeftNavigationController

@synthesize lineView=_lineView;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - authentication

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification {
    [super authenticationViewControllerdidAuthenticateUserCallback:notification];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = nil;
    self.tableView.tableFooterView = nil;
    self.tableView.tableHeaderView = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds)-2.0f, 0.0f, 2.0f, CGRectGetHeight(self.view.bounds));
    GHPEdgedLineView *lineView = [[[GHPEdgedLineView alloc] initWithFrame:frame] autorelease];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:lineView];
    
    self.lineView = lineView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.lineView = nil;
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
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // Username
    // News Feed, My Actions, Organizations
    // My Profile
    // Search
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCellUser";
        
        GHPLeftNavigationControllerTableViewCell *cell = (GHPLeftNavigationControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier] 
                    autorelease];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = [GHAuthenticationManager sharedInstance].username;
        NSString *gravatarID = [GHSettingsHelper gravatarID];
        UIImage *gravatarImage = [[UIImage cachedImageFromGravatarID:gravatarID] resizedImage:CGSizeMake(48.0f, 48.0f) 
                                                                         interpolationQuality:kCGInterpolationHigh];
        
        if (gravatarImage) {
            cell.imageView.image = gravatarImage;
        } else {
            [UIImage imageFromGravatarID:gravatarID 
                   withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                       if ([self.tableView containsIndexPath:indexPath]) {
                           [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                       }
                   }];
        }
        
        return cell;
    } else {
        NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCell";
        
        GHPLeftNavigationControllerTableViewCell *cell = (GHPLeftNavigationControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier] 
                    autorelease];
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"News Feed", @"");
            [cell setItemImage:[UIImage imageNamed:@"56-feed.png"] ];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"My Actions", @"");
            [cell setItemImage:nil ];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Organizations", @"");
            [cell setItemImage:nil ];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"My Profile", @"");
            [cell setItemImage:[UIImage imageNamed:@"145-persondot.png"] ];
        } else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Search", @"");
            [cell setItemImage:[UIImage imageNamed:@"Lupe.PNG"] ];
        }
        
        return cell;
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 60.0f;
    }
    return 44.0f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.lineView.frame;
    frame.origin.y = scrollView.bounds.origin.y;
    self.lineView.frame = frame;
}

#pragma mark - memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_lineView release];
    [super dealloc];
}

@end
