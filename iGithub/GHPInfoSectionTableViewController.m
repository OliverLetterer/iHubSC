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
            cell = [[[GHPInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:CellIdentifier]
                    autorelease];
        }
        
        if (!self.canDisplayActionButton) {
            [cell.actionButton removeFromSuperview];
        }
        
        cell.delegate = self;
        
        [_infoCell release], _infoCell = [cell retain];
    }
    return _infoCell;
}

- (UIActionSheet *)actionButtonActionSheet {
    return nil;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)canDisplayActionButtonActionSheet {
    return YES;
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

#pragma mark - Memory management

- (void)dealloc {
    [_infoCell release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    [_infoCell release], _infoCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
    if (!self.canDisplayActionButtonActionSheet) {
        [self setActionButtonActive:YES];
        [self downloadDataToDisplayActionButton];
    } else {
        [self setActionButtonActive:NO];
        UIActionSheet *sheet = self.actionButtonActionSheet;
        
        [sheet showFromRect:[cell.actionButton convertRect:cell.actionButton.bounds toView:self.view] 
                     inView:self.view 
                   animated:YES];
    }

}

@end
