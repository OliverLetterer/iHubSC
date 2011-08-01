//
//  GHPInfoSectionTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPInfoSectionTableViewController.h"


@implementation GHPInfoSectionTableViewController

#pragma mark - setters and getters

- (GHPInfoTableViewCell *)infoCell {
    if (!_infoCell && self.isViewLoaded) {
        static NSString *CellIdentifier = @"GHPInfoTableViewCell";
        GHPInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHPInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:CellIdentifier];
        }
        
        if (!self.canDisplayActionButton) {
            [cell.actionButton removeFromSuperview];
        }
        
        cell.delegate = self;
        
        _infoCell = cell;
    }
    return _infoCell;
}

- (UIActionSheet *)actionButtonActionSheet {
    return nil;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    return NO;
}

- (void)setActionButtonActive:(BOOL)actionButtonActive {
    if (actionButtonActive) {
        self.infoCell.actionButton.alpha = 0.0f;
        [self.infoCell.activityIndicatorView startAnimating];
    } else {
        self.infoCell.actionButton.alpha = 1.0f;
        [self.infoCell.activityIndicatorView stopAnimating];
    }
}

- (BOOL)isActionButtonActive {
    return self.infoCell.activityIndicatorView.isAnimating;
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    _infoCell = nil;
}

#pragma Action Button Downloading

- (void)downloadDataToDisplayActionButton {
    
}

- (void)didDownloadDataToDisplayActionButton {
    [self setActionButtonActive:NO];
    [self infoTableViewCellActionButtonClicked:self.infoCell];
}

- (void)failedToDownloadDataToDisplayActionButtonWithError:(NSError *)error {
    [self setActionButtonActive:NO];
    [self handleError:error];
}

#pragma mark - GHPInfoTableViewCellDelegate

- (void)infoTableViewCellActionButtonClicked:(GHPInfoTableViewCell *)cell {
    if (self.needsToDownloadDataToDisplayActionButtonActionSheet) {
        [self setActionButtonActive:YES];
        [self downloadDataToDisplayActionButton];
    } else {
        [self setActionButtonActive:NO];
        UIActionSheet *sheet = self.actionButtonActionSheet;
        
        if (self.isViewLoaded) {
            [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                         inView:self.view 
                       animated:YES];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _currentPopoverController = nil;
}

#pragma mark - instance methods

- (void)presentViewControllerFromActionButton:(UIViewController *)viewController detatchNavigationController:(BOOL)detatchNavigationController animated:(BOOL)animted {
    if (detatchNavigationController) {
        viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    _currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
    _currentPopoverController.delegate = self;
    [_currentPopoverController presentPopoverFromRect:[self.infoCell.actionButton convertRect:self.infoCell.actionButton.bounds toView:self.advancedNavigationController.view] inView:self.advancedNavigationController.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

@end
