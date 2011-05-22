//
//  GHViewMilestoneViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHTableViewController.h"

@interface GHViewMilestoneViewController : GHTableViewController {
@private
    GHAPIMilestoneV3 *_milestone;
    
    NSString *_repository;
    NSNumber *_milestoneNumber;
    
    NSArray *_openIssues;
    NSInteger _openIssuesNextPage;
    
    NSArray *_closedIssues;
    NSInteger _closedIssuesNextPage;
}

@property (nonatomic, retain) GHAPIMilestoneV3 *milestone;

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *milestoneNumber;

@property (nonatomic, retain) NSArray *openIssues;
@property (nonatomic, retain) NSArray *closedIssues;

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber;

- (void)downloadMilestoneData;

- (void)cacheHeightForOpenIssuesArray;
- (void)cacheHeightForClosedIssuesArray;

@end
