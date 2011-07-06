//
//  GHViewIssueTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHAPIIssueV3, GHNewsFeedItemTableViewCell, GHIssueComment, GHPullRequestDiscussion;

@interface GHViewIssueTableViewController : GHTableViewController {
@private
    GHAPIIssueV3 *_issue;
    
    NSString *_repository;
    NSNumber *_number;
    
    BOOL _isDownloadingIssueData;
    
    BOOL _canUserAdministrateIssue;
    
    NSArray *_history;
    GHPullRequestDiscussion *_discussion;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
}

#warning add ability to close an issue and merge a pull request

@property (nonatomic, retain) GHAPIIssueV3 *issue;
@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *number;

@property (nonatomic, readonly) NSString *issueName;

@property (nonatomic, retain) NSArray *history;
@property (nonatomic, retain) GHPullRequestDiscussion *discussion;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number;

- (void)downloadIssueData;

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;
- (void)titleTableViewCellLongPressRecognized:(UILongPressGestureRecognizer *)recognizer;

@end
