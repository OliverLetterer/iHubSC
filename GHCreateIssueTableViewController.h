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

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHRawIssue *)issue;
- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController;

@end



@interface GHCreateIssueTableViewController : GHTableViewController {
@private
    id<GHCreateIssueTableViewControllerDelegate> _delegate;
    NSString *_repository;
}

@property (nonatomic, assign) id<GHCreateIssueTableViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *repository;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

- (id)initWithRepository:(NSString *)repository;

@end
