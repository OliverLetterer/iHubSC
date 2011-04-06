//
//  PullToRefreshTableViewController.h
//  ASiST
//
//  Created by Oliver on 09.12.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface PullToRefreshTableViewController : UITableViewController {
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL checkForRefresh;
	BOOL reloading;
    
    BOOL _pullToReleaseEnabled;
}

@property (nonatomic, assign) BOOL pullToReleaseEnabled;

- (void)dataSourceDidFinishLoadingNewData;
- (void)showReloadAnimationAnimated:(BOOL)animated;

- (void)pullRefreshAnimated:(BOOL)animated;

@end