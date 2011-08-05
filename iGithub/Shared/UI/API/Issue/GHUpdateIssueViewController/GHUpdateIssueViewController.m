//
//  GHUpdateIssueViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUpdateIssueViewController.h"
#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"

@implementation GHUpdateIssueViewController
@synthesize issue=_issue;

#pragma mark - setters and getters

- (void)setIssue:(GHAPIIssueV3 *)issue {
    if (issue != _issue) {
        _issue = issue;
        
        self.selectedMilestoneNumber = issue.milestone.number;
        self.assigneeString = issue.assignee.login;
        self.repository = issue.repository;
        
        [issue.labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GHAPILabelV3 *label = obj;
            [self.selectedLabels addObject:label.name];
        }];
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithIssue:(GHAPIIssueV3 *)issue {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        // Custom initialization
        self.issue = issue;
        
        self.title = NSLocalizedString(@"Edit", @"");
    }
    return self;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (!_didUpdateFirstCell) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([cell isKindOfClass:GHPCreateIssueTitleAndDescriptionTableViewCell.class]) {
                GHPCreateIssueTitleAndDescriptionTableViewCell *issueCell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)cell;
                
                issueCell.textField.text = self.issue.title;
                issueCell.textView.text = self.issue.body;
            }
        } else {
            if ([cell isKindOfClass:GHCreateIssueTableViewCell.class]) {
                GHCreateIssueTableViewCell *issueCell = (GHCreateIssueTableViewCell *)cell;
                
                issueCell.titleTextField.text = self.issue.title;
                issueCell.textView.text = self.issue.body;
            }
        }
        _didUpdateFirstCell = YES;
    }
    
    return cell;
}

#pragma mark - super implementation

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    NSString *title = nil;
    NSString *body = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GHPCreateIssueTitleAndDescriptionTableViewCell *cell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateIssueTableViewControllerSectionTitle] ];
        
        title = cell.textField.text;
        body = cell.textView.text;
    } else {
        GHCreateIssueTableViewCell *cell = (GHCreateIssueTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateIssueTableViewControllerSectionTitle] ];
        
        title = cell.titleTextField.text;
        body = cell.textView.text;
    }
    
    [GHAPIIssueV3 updateIssueOnRepository:self.repository withNumber:self.issue.number 
                                    title:title 
                                     body:body 
                                 assignee:self.assigneeString ? self.assigneeString : (id)[NSNull null]
                                    state:self.issue.state 
                                milestone:self.selectedMilestoneNumber ? self.selectedMilestoneNumber : (id)[NSNull null]
                                   labels:self.selectedLabels.count > 0 ? self.selectedLabels : (id)[NSNull null]
                        completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                [self handleError:error];
                            } else {
                                [self.delegate createIssueViewController:self didCreateIssue:issue];
                            }
                        }];
}

@end
