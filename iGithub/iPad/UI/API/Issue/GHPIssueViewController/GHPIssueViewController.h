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
#import "GHPAttributedTableViewCell.h"
#import "GHPNewCommentTableViewCell.h"
#import "GHUpdateIssueViewController.h"

@interface GHPIssueViewController : GHPInfoSectionTableViewController <UIAlertViewDelegate, GHPIssueInfoTableViewCellDelegate, GHPAttributedTableViewCellDelegate, NSCoding, GHPNewCommentTableViewCellDelegate, GHCreateIssueTableViewControllerDelegate, UIPopoverControllerDelegate> {
@private
    NSString *_repositoryString;
    NSNumber *_issueNumber;
    
    GHAPIIssueV3 *_issue;
    GHAPIRepositoryV3 *_repository;
    
    GHPullRequestDiscussion *_discussion;
    NSMutableArray *_history;
    
    BOOL _hasCollaboratorData;
    BOOL _isCollaborator;
    BOOL _isCreatorOfIssue;
    
    CGFloat _bodyHeight;
    
    NSURL *_selectedURL;
    
    NSString *_lastUserComment;
    
    UIPopoverController *_currentPopoverController;
}

@property (nonatomic, copy) NSString *lastUserComment;

@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) GHAPIIssueV3 *issue;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;

@property (nonatomic, retain) GHPullRequestDiscussion *discussion;
@property (nonatomic, retain) NSMutableArray *history;

@property (nonatomic, readonly) NSString *issueName;

@property (nonatomic, copy, readonly) NSString *repositoryString;
@property (nonatomic, copy, readonly) NSNumber *issueNumber;
- (void)setIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (id)initWithIssueNumber:(NSNumber *)issueNumber onRepository:(NSString *)repositoryString;

- (NSString *)descriptionForIssueEvent:(GHAPIIssueEventV3 *)event;

- (void)cacheHeightsForHistroy;

@end
