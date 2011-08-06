//
//  GHUpdateMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUpdateMilestoneViewController.h"
#import "GHCreateMilestoneTitleAndDescriptionTableViewCell.h"
#import "GHPCreateMilestoneTitleAndDescriptionTableViewCell.h"

@implementation GHUpdateMilestoneViewController
@synthesize milestone=_milestone;

#pragma mark - setters and getters

- (void)setMilestone:(GHAPIMilestoneV3 *)milestone {
    if (milestone != _milestone) {
        _milestone = milestone;
        
        self.title = _milestone.title;
        self.selectedDueDate = _milestone.dueOn.dateFromGithubAPIDateString;
    }
}

#pragma mark - Initialization

- (id)initWithMilestone:(GHAPIMilestoneV3 *)milestone repository:(NSString *)repository {
    if ((self = [super init])) {
        self.milestone = milestone;
        self.repository = repository;
    }
    return self;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (!_didUpdateFirstCell) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([cell isKindOfClass:GHPCreateIssueTitleAndDescriptionTableViewCell.class]) {
                GHPCreateMilestoneTitleAndDescriptionTableViewCell *issueCell = (GHPCreateMilestoneTitleAndDescriptionTableViewCell *)cell;
                
                issueCell.textField.text = self.milestone.title;
                issueCell.textView.text = self.milestone.milestoneDescription;
            }
        } else {
            if ([cell isKindOfClass:GHCreateMilestoneTitleAndDescriptionTableViewCell.class]) {
                GHCreateMilestoneTitleAndDescriptionTableViewCell *issueCell = (GHCreateMilestoneTitleAndDescriptionTableViewCell *)cell;
                
                issueCell.titleTextField.text = self.milestone.title;
                issueCell.textView.text = self.milestone.milestoneDescription;
            }
        }
        _didUpdateFirstCell = YES;
    }
    
    return cell;
}

#pragma mark - super implementation

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    NSString *title = nil;
    NSString *description = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GHPCreateMilestoneTitleAndDescriptionTableViewCell *cell = (GHPCreateMilestoneTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription] ];
        
        title = cell.textField.text;
        description = cell.textView.text;
    } else {
        GHCreateMilestoneTitleAndDescriptionTableViewCell *cell = (GHCreateMilestoneTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription] ];
        
        title = cell.titleTextField.text;
        description = cell.textView.text;
    }
    
    self.navigationItem.rightBarButtonItem = self.loadingButton;
    [GHAPIMilestoneV3 updateMilestoneOnRepository:self.repository withID:self.milestone.number 
                                            title:title description:description dueOn:self.selectedDueDate 
                                completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                                    self.navigationItem.rightBarButtonItem = self.saveButton;
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self.delegate createMilestoneViewController:self didCreateMilestone:milestone];
                                    }
                                }];
}

@end
