//
//  GHCreateMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateMilestoneViewController.h"
#import "GHCreateMilestoneTitleAndDescriptionTableViewCell.h"
#import "GHPCreateMilestoneTitleAndDescriptionTableViewCell.h"

NSInteger const kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription = 0;
NSInteger const kGHCreateMilestoneViewControllerTableViewSectionDueDate = 1;

NSInteger const kGHCreateMilestoneViewControllerTableViewNumberOfSections = 2;

@implementation GHCreateMilestoneViewController
@synthesize delegate=_delegate;
@synthesize repository=_repository;
@synthesize selectedDueDate=_selectedDueDate;

#pragma mark - setters and getters

- (void)setSelectedDueDate:(NSDate *)selectedDueDate {
    if (selectedDueDate != _selectedDueDate) {
        _selectedDueDate = selectedDueDate;
        
        if (self.isViewLoaded) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kGHCreateMilestoneViewControllerTableViewSectionDueDate] 
                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"New Milestone", @"");
        self.repository = repository;
    }
    return self;
}

#pragma mark - target actions

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
    
    [GHAPIMilestoneV3 createMilestoneOnRepository:self.repository title:title description:description dueOn:self.selectedDueDate
                                completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self.delegate createMilestoneViewController:self didCreateMilestone:milestone];
                                    }
                                }];
}

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createMilestoneViewControllerDidCancel:self];
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
    return kGHCreateMilestoneViewControllerTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription) {
        return 1;
    } else if (section == kGHCreateMilestoneViewControllerTableViewSectionDueDate) {
        return 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription) {
        if (indexPath.row == 0) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                static NSString *CellIdentifier = @"GHPCreateIssueTitleAndDescriptionTableViewCell";
                
                GHPCreateMilestoneTitleAndDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPCreateMilestoneTitleAndDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                return cell;
            } else {
                static NSString *CellIdentifier = @"GHCreateMilestoneTitleAndDescriptionTableViewCell";
                
                GHCreateMilestoneTitleAndDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHCreateMilestoneTitleAndDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                return cell;
            }
        }
    } else if (indexPath.section == kGHCreateMilestoneViewControllerTableViewSectionDueDate) {
        if (indexPath.row == 0) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
                GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (self.selectedDueDate) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due on: %@", @""), [dateFormatter stringFromDate:self.selectedDueDate]];
                } else {
                    cell.textLabel.text = NSLocalizedString(@"No Due Date selected", @"");
                }
                
                return cell;
            } else {
                static NSString *CellIdentifier = @"GHTableViewCellWithLinearGradientBackgroundView";
                
                GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (self.selectedDueDate) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Due on: %@", @""), [dateFormatter stringFromDate:self.selectedDueDate]];
                } else {
                    cell.textLabel.text = NSLocalizedString(@"No Due Date selected", @"");
                }
                
                return cell;
            }
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription) {
        if (indexPath.row == 0) {
            return 200.0f;
        }
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kGHCreateMilestoneViewControllerTableViewSectionDueDate) {
        GHDateSelectViewController *viewController = [[GHDateSelectViewController alloc] initWithSelectedDate:self.selectedDueDate ? self.selectedDueDate : [NSDate date]];
        viewController.dateDelegate = self;
        viewController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - GHDateSelectViewControllerDelegate

- (void)dateSelectViewController:(GHDateSelectViewController *)viewController didSelectDate:(NSDate *)date {
    self.selectedDueDate = date;
}

- (void)dateSelectViewControllerDidCancel:(GHDateSelectViewController *)viewController {
    self.selectedDueDate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
