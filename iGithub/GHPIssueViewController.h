//
//  GHPIssueViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPRepositoryInfoTableViewCell.h"

@interface GHPIssueViewController : GHTableViewController <GHPRepositoryInfoTableViewCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
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
    
    GHPRepositoryInfoTableViewCell *_infoCell;
}

@property (nonatomic, retain) GHAPIIssueV3 *issue;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;

@property (nonatomic, retain) GHPullRequestDiscussion *discussion;
@property (nonatomic, retain) NSMutableArray *history;

@property (nonatomic, readonly) NSString *issueName;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;

@property (nonatomic, retain) GHPRepositoryInfoTableViewCell *infoCell;

@property (nonatomic, copy, readonly) NSString *repositoryString;
@property (nonatomic, copy, readonly) NSNumber *issueNumber;
- (void)setIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (id)initWithIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (NSString *)descriptionForIssueEvent:(GHAPIIssueEventV3 *)event;

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton;
- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton;

@end
