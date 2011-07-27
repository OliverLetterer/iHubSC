//
//  GHPullToReleaseTableViewController.h
//  iGithub
//
//  Created by me on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPullToReleaseTableHeaderView.h"

@class GHPullToReleaseTableViewController;

@protocol GHPullToReleaseTableViewControllerDelegate <NSObject>

@end



@interface GHPullToReleaseTableViewController : UITableViewController {
@private
    GHPullToReleaseTableHeaderView *_pullToReleaseHeaderView;
    
    BOOL _isReloadingData;
    BOOL _pullToReleaseEnabled;
    
    UIEdgeInsets _defaultEdgeInset;
    
    NSDate *_lastUpdateDate;
}

@property (nonatomic, retain) GHPullToReleaseTableHeaderView *pullToReleaseHeaderView;

@property (nonatomic, assign) BOOL pullToReleaseEnabled;

@property (nonatomic, readonly) CGFloat dragDistance;

@property (nonatomic, assign) UIEdgeInsets defaultEdgeInset;

@property (nonatomic, retain) NSDate *lastUpdateDate;

- (void)pullToReleaseTableViewReloadData;
- (void)pullToReleaseTableViewDidReloadData;


@end
