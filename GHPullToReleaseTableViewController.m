//
//  GHPullToReleaseTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullToReleaseTableViewController.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"

#define kGHPullToReleaseTableViewControllerDefaultAnimationDuration 0.3f

NSString *const NSUserDefaultLastUpdateDateKey = @"NSUserDefaultLastUpdateDateKey";

@implementation GHPullToReleaseTableViewController

@synthesize pullToReleaseHeaderView=_pullToReleaseHeaderView;
@synthesize pullToReleaseEnabled=_pullToReleaseEnabled;
@synthesize defaultEdgeInset=_defaultEdgeInset;
@synthesize lastUpdateDate=_lastUpdateDate;

#pragma mark - setters and getters

- (CGFloat)dragDistance {
    return kGHPullToReleaseTableHeaderViewPreferedHeaderHeight + _defaultEdgeInset.top;
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate {
    if (lastUpdateDate != _lastUpdateDate) {
        [_lastUpdateDate release], _lastUpdateDate = [lastUpdateDate retain];
        
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdateDate forKey:NSUserDefaultLastUpdateDateKey];
    }
}

- (NSDate *)lastUpdateDate {
    if (!_lastUpdateDate) {
        _lastUpdateDate = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultLastUpdateDateKey] retain];
    }
    return _lastUpdateDate;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_pullToReleaseHeaderView release];
    [_lastUpdateDate release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.pullToReleaseEnabled) {
        return;
    }
    self.pullToReleaseHeaderView = [[[GHPullToReleaseTableHeaderView alloc] initWithFrame:CGRectMake(0.0, - kGHPullToReleaseTableHeaderViewPreferedHeaderHeight - _defaultEdgeInset.top, 320.0f, kGHPullToReleaseTableHeaderViewPreferedHeaderHeight)] autorelease];
    self.pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
    [self.tableView addSubview:self.pullToReleaseHeaderView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_pullToReleaseHeaderView release], _pullToReleaseHeaderView = nil;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", indexPath];
    
    // Configure the cell...
    
    return cell;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - PullImplementation

- (void)pullToReleaseTableViewReloadData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    CGFloat dragDistance = -self.dragDistance;
    
    _isReloadingData = YES;
    self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateLoading;
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = UIEdgeInsetsMake(- dragDistance, 0.0, 0.0, 0.0);
                     } 
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.tableView setContentOffset:CGPointMake(0.0f, dragDistance) animated:YES];
                         }
                     }];
}

- (void)pullToReleaseTableViewDidReloadData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    self.lastUpdateDate = [NSDate date];
    self.pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = self.defaultEdgeInset;
                     } 
                     completion:^(BOOL finished) {
                         _isReloadingData = NO;
                         self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    if (!_isReloadingData) {
        CGFloat dragDistance = -self.dragDistance;
        
        if (scrollView.contentOffset.y <= dragDistance) {
            [self pullToReleaseTableViewReloadData];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    if (!_isReloadingData) {
        CGFloat dragDistance = -self.dragDistance;
        
        if (scrollView.contentOffset.y <= dragDistance) {
            self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateDraggedDown;
        } else {
            self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
        }
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.tableView.style forKey:@"tableViewStyle"];
    [encoder encodeBool:_pullToReleaseEnabled forKey:@"pullToReleaseEnabled"];
    [encoder encodeUIEdgeInsets:_defaultEdgeInset forKey:@"defaultEdgeInset"];
    [encoder encodeObject:_lastUpdateDate forKey:@"lastUpdateDate"];
    [encoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithStyle:[decoder decodeIntegerForKey:@"tableViewStyle"]])) {
        _pullToReleaseEnabled = [decoder decodeBoolForKey:@"pullToReleaseEnabled"];
        _defaultEdgeInset = [decoder decodeUIEdgeInsetsForKey:@"defaultEdgeInset"];
        _lastUpdateDate = [[decoder decodeObjectForKey:@"lastUpdateDate"] retain];
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
