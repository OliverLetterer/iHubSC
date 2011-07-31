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
- (void)createIssueViewController:(GHPCreateIssueViewController *)createIssueViewController didCreateIssue:(GHAPIIssueV3 *)issue;

@end



@interface GHPCreateIssueViewController : GHTableViewController {
@private
    id<GHPCreateIssueViewControllerDelegate> __weak _delegate;
    
    NSMutableArray *_collaborators;
    NSString *_assigneeString;
    
    BOOL _hasCollaboratorState;
    BOOL _isCollaborator;
    NSMutableArray *_milestones;
    NSNumber *_selectedMilestoneNumber;
    
    NSString *_repository;
}

@property (nonatomic, weak) id<GHPCreateIssueViewControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, copy) NSString *repository;

@property (nonatomic, copy) NSString *assigneeString;
@property (nonatomic, copy) NSNumber *selectedMilestoneNumber;



- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

- (id)initWithRepository:(NSString *)repository delegate:(id<GHPCreateIssueViewControllerDelegate>)delegate;

@end
