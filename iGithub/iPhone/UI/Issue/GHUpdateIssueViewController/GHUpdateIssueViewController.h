//
//  GHUpdateIssueViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHCreateIssueTableViewController.h"

@interface GHUpdateIssueViewController : GHCreateIssueTableViewController {
@private
    GHAPIIssueV3 *_issue;
    
    BOOL _canAssignMilestoneAndAssignee;
    
    BOOL _didUpdateFirstCell;
}

@property (nonatomic, retain) GHAPIIssueV3 *issue;

- (id)initWithIssue:(GHAPIIssueV3 *)issue canAssignMilestoneAndAssignee:(BOOL)canAssignMilestoneAndAssignee;

@end
