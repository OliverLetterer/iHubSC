//
//  PullToRefreshTableViewController.m
//  ASiST
//
//  Created by Oliver on 09.12.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "PullToRefreshTableViewController.h"

#define kReleaseToReloadStatus 0
#define kPullToReloadStatus 1
#define kLoadingStatus 2

@implementation PullToRefreshTableViewController

@synthesize pullToReleaseEnabled=_pullToReleaseEnabled;

- (void)viewDidLoad  {
    [super viewDidLoad];
    
    if (!self.pullToReleaseEnabled) {
        return;
    }
	refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, 320.0f, self.view.bounds.size.height)];
	[self.tableView addSubview:refreshHeaderView];
	self.tableView.showsVerticalScrollIndicator = YES;
}

- (void)dealloc {
	[refreshHeaderView release];
    [super dealloc];
}

#pragma mark State Changes

- (void)showReloadAnimationAnimated:(BOOL)animated {
    if (!self.pullToReleaseEnabled) {
        return;
    }
	reloading = YES;
	[refreshHeaderView toggleActivityView:YES];
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	} else {
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
	}
}

- (void)reloadTableViewDataSource {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    [self doesNotRecognizeSelector:@selector(reloadTableViewDataSource)];
}

- (void)pullRefreshAnimated:(BOOL)animated {
    if (!self.pullToReleaseEnabled) {
        return;
    }
	[self.tableView setContentOffset:CGPointMake(0, -65.0f) animated:animated];
	[self showReloadAnimationAnimated:NO];
	[self reloadTableViewDataSource];
}

- (void)dataSourceDidFinishLoadingNewData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
	reloading = NO;
	[refreshHeaderView flipImageAnimated:NO];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[refreshHeaderView setStatus:kPullToReloadStatus];
	[refreshHeaderView toggleActivityView:NO];
    [refreshHeaderView setLastUpdatedDate:[NSDate date]];
	[UIView commitAnimations];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	return cell;
}

#pragma mark Scrolling Overrides
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.pullToReleaseEnabled) {
        return;
    }
	if (!reloading) {
		checkForRefresh = YES;  //  only check offset when dragging
		// refresh the pretty-printed last update date
		refreshHeaderView.lastUpdatedDate = refreshHeaderView.lastUpdatedDate;
	}
} 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.pullToReleaseEnabled) {
        return;
    }
	if (reloading) return;
	if (checkForRefresh) {
		if (refreshHeaderView.isFlipped && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kPullToReloadStatus];
		} else if (!refreshHeaderView.isFlipped && scrollView.contentOffset.y < -65.0f) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kReleaseToReloadStatus];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.pullToReleaseEnabled) {
        return;
    }
	if (reloading) return;
	if (scrollView.contentOffset.y <= - 65.0f) {
		if ([self.tableView.dataSource respondsToSelector:@selector(reloadTableViewDataSource)]) {
			[self showReloadAnimationAnimated:YES];
			[self reloadTableViewDataSource];
		}
	} 
	checkForRefresh = NO;
}

@end