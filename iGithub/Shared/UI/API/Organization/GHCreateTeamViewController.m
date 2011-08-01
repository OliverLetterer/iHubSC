//
//  GHCreateTeamViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateTeamViewController.h"

NSInteger const kGHCreateTeamViewControllerTableViewNumberOfSections = 0;

@implementation GHCreateTeamViewController
@synthesize delegate=_delegate, organization=_organization;

#pragma mark - setters and getters

#pragma mark - Initialization

- (id)initWithOrganization:(NSString *)organization {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        self.organization = organization;
        self.title = NSLocalizedString(@"Create Team", @"");
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isPresentedInPopoverController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self 
                                                                                      action:@selector(cancelButtonClicked:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    self.navigationController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                target:self 
                                                                                action:@selector(saveButtonClicked:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kGHCreateTeamViewControllerTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - target actions

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
//    NSString *title = nil;
//    NSString *description = nil;
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        GHPCreateMilestoneTitleAndDescriptionTableViewCell *cell = (GHPCreateMilestoneTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription] ];
//        
//        title = cell.textField.text;
//        description = cell.textView.text;
//    } else {
//        GHCreateMilestoneTitleAndDescriptionTableViewCell *cell = (GHCreateMilestoneTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription] ];
//        
//        title = cell.titleTextField.text;
//        description = cell.textView.text;
//    }
//    
//    [GHAPIMilestoneV3 createMilestoneOnRepository:self.repository title:title description:description dueOn:self.selectedDueDate
//                                completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
//                                    if (error) {
//                                        [self handleError:error];
//                                    } else {
//                                        [self.delegate createMilestoneViewController:self didCreateMilestone:milestone];
//                                    }
//                                }];
}

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createTeamViewControllerDidCancel:self];
}

@end
