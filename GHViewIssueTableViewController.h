//
//  GHViewIssueTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHIssue, GHNewsFeedItemTableViewCell, GHIssueComment;

@interface GHViewIssueTableViewController : GHTableViewController {
@private
    GHIssue *_issue;
    
    NSString *_repository;
    NSNumber *_number;
    
    BOOL _isDownloadingIssueData;
    BOOL _canUserAdministrateIssue;
    
    NSArray *_comments;
    BOOL _isShowingComments;
    BOOL _isDownloadingComments;
    
    UITextView *_textView;
    
    UIToolbar *_textViewToolBar;
}

@property (nonatomic, retain) GHIssue *issue;
@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *number;

@property (nonatomic, retain) NSArray *comments;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number;

- (void)downloadIssueData;

- (void)showComments;
- (void)hideComments;
- (void)downloadComments;

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;

@end
