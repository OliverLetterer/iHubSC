//
//  GHViewIssueTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHActionButtonTableViewController.h"
#import "GHAttributedTableViewCell.h"
#import "GHNewCommentTableViewCell.h"
#import "GHUpdateIssueViewController.h"

@class GHAPIIssueV3, GHTableViewCell, GHIssueComment, GHPullRequestDiscussion, DTAttributedTextView;

@interface GHIssueViewController : GHActionButtonTableViewController <UIAlertViewDelegate, GHAttributedTableViewCellDelegate, GHNewCommentTableViewCellDelegate, GHCreateIssueTableViewControllerDelegate> {
@private
    GHAPIIssueV3 *_issue;
    
    NSString *_repository;
    NSNumber *_number;
    
    NSArray *_history;
    GHPullRequestDiscussion *_discussion;
    
    BOOL _hasCollaboratorData;
    
    BOOL _isCollaborator;
    BOOL _isCreatorOfIssue;
    
    NSString *_lastUserComment;
}

@property (nonatomic, copy) NSString *lastUserComment;

@property (nonatomic, retain) GHAPIIssueV3 *issue;
@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *number;

@property (nonatomic, readonly) NSString *issueName;

@property (nonatomic, retain) NSArray *history;
@property (nonatomic, retain) GHPullRequestDiscussion *discussion;

- (NSString *)descriptionForEvent:(GHAPIIssueEventV3 *)event;

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number;

- (void)downloadIssueData;

- (void)cacheHeightsForHistroy;

@end
