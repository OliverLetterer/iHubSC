//
//  GHPCreateIssueViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHPCreateIssueViewController;

@protocol GHPCreateIssueViewControllerDelegate <NSObject>

- (void)createIssueViewControllerIsDone:(GHPCreateIssueViewController *)createIssueViewController;

@end



@interface GHPCreateIssueViewController : GHTableViewController {
@private
    id<GHPCreateIssueViewControllerDelegate> _delegate;
    
    NSMutableArray *_collaborators;
    NSUInteger _assignIndex;
    
    BOOL _hasCollaboratorState;
    BOOL _isCollaborator;
    NSMutableArray *_milestones;
    NSUInteger _assignesMilestoneIndex;
    
    NSString *_repository;
}

@property (nonatomic, assign) id<GHPCreateIssueViewControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, copy) NSString *repository;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

- (id)initWithRepository:(NSString *)repository delegate:(id<GHPCreateIssueViewControllerDelegate>)delegate;

@end
