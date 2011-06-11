//
//  GHCreateIssueTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@class GHCreateIssueTableViewController;

@protocol GHCreateIssueTableViewControllerDelegate <NSObject>

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHAPIIssueV3 *)issue;
- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController;

@end



@interface GHCreateIssueTableViewController : GHTableViewController {
@private
    id<GHCreateIssueTableViewControllerDelegate> _delegate;
    NSString *_repository;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
    
    NSArray *_collaborators;
    NSUInteger _assignIndex;
    
    NSMutableArray *_milestones;
    NSUInteger _assignesMilestoneIndex;
}

@property (nonatomic, assign) id<GHCreateIssueTableViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *repository;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

@property (nonatomic, retain) NSArray *collaborators;
@property (nonatomic, retain) NSMutableArray *milestones;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;

- (id)initWithRepository:(NSString *)repository;

@end
