//
//  GHPIssueViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPInfoSectionTableViewController.h"
#import "GHPIssueInfoTableViewCell.h"
#import "GHPIssueCommentTableViewCell.h"

@interface GHPIssueViewController : GHPInfoSectionTableViewController <UIAlertViewDelegate, GHPIssueInfoTableViewCellDelegate, GHPIssueCommentTableViewCellDelegate, UITextViewDelegate> {
@private
    NSString *_repositoryString;
    NSNumber *_issueNumber;
    
    GHAPIIssueV3 *_issue;
    GHAPIRepositoryV3 *_repository;
    
    GHPullRequestDiscussion *_discussion;
    NSMutableArray *_history;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
    
    BOOL _hasCollaboratorData;
    BOOL _isCollaborator;
    
    CGFloat _bodyHeight;
    
    NSString *_linkText;
    NSString *_linkURL;
}

@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) NSString *linkURL;

@property (nonatomic, retain) GHAPIIssueV3 *issue;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;

@property (nonatomic, retain) GHPullRequestDiscussion *discussion;
@property (nonatomic, retain) NSMutableArray *history;

@property (nonatomic, readonly) NSString *issueName;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

@property (nonatomic, copy, readonly) NSString *repositoryString;
@property (nonatomic, copy, readonly) NSNumber *issueNumber;
- (void)setIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (id)initWithIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (NSString *)descriptionForIssueEvent:(GHAPIIssueEventV3 *)event;

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarFormatButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarInsertButtonClicked:(UIBarButtonItem *)barButton;

- (void)cacheHeightsForHistroy;

@end
