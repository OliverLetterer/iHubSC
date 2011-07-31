//
//  GHPUpdateIssueViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPUpdateIssueViewController.h"
#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"

@implementation GHPUpdateIssueViewController
@synthesize issue=_issue;

#pragma mark - setters and getters

- (void)setIssue:(GHAPIIssueV3 *)issue {
    if (issue != _issue) {
        _issue = issue;
        
        self.selectedMilestoneNumber = issue.milestone.number;
        self.assigneeString = issue.assignee.login;
        self.repository = issue.repository;
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithIssue:(GHAPIIssueV3 *)issue canAssignMilestoneAndAssignee:(BOOL)canAssignMilestoneAndAssignee {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        _canAssignMilestoneAndAssignee = canAssignMilestoneAndAssignee;
        self.issue = issue;
        
        self.title = NSLocalizedString(@"Edit", @"");
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((section == kGHPCreateIssueTableViewControllerSectionAssignee || section == kGHPCreateIssueTableViewControllerSectionMilestones) && !_canAssignMilestoneAndAssignee) {
        return 0;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (!_didUpdateFirstCell) {
        if ([cell isKindOfClass:GHPCreateIssueTitleAndDescriptionTableViewCell.class]) {
            GHPCreateIssueTitleAndDescriptionTableViewCell *issueCell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)cell;
            
            issueCell.textField.text = self.issue.title;
            issueCell.textView.text = self.issue.body;
            _didUpdateFirstCell = YES;
        }
    }
    
    return cell;
}

#pragma mark - super implementation

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    GHPCreateIssueTitleAndDescriptionTableViewCell *cell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHPCreateIssueTableViewControllerSectionTitle] ];
    
    [GHAPIIssueV3 updateIssueOnRepository:self.repository withNumber:self.issue.number 
                                    title:cell.textField.text 
                                     body:cell.textView.text 
                                 assignee:self.assigneeString 
                                    state:self.issue.state 
                                milestone:self.selectedMilestoneNumber 
                                   labels:nil 
                        completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                [self handleError:error];
                            } else {
                                [self.delegate createIssueViewController:self didCreateIssue:issue];
                            }
                        }];
}

@end
