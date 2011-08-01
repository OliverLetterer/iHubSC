//
//  GHActionButtonTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHActionButtonTableViewController.h"

NSInteger const kUIActionButtonActionSheetTag = 549532;

@implementation GHActionButtonTableViewController

#pragma mark - setters and getters

- (UIBarButtonItem *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return _actionButton;
}

- (UIBarButtonItem *)loadingActionButton {
    if (!_loadingActionButton) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicatorView startAnimating];
        _loadingActionButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
        _loadingActionButton.enabled = NO;
        _loadingActionButton.style = UIBarButtonItemStyleBordered;
    }
    return _loadingActionButton;
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
        self.navigationItem.rightBarButtonItem = self.loadingActionButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.actionButton;
    }
}

- (BOOL)isActionButtonActive {
    return self.navigationItem.rightBarButtonItem == self.loadingActionButton;
}

#pragma Action Button Downloading

- (void)downloadDataToDisplayActionButton {
    
}

- (void)didDownloadDataToDisplayActionButton {
    self.actionButtonActive = NO;
    [self actionButtonClicked:self.actionButton];
}

- (void)failedToDownloadDataToDisplayActionButtonWithError:(NSError *)error {
    self.actionButtonActive = NO;
    [self handleError:error];
}

- (void)actionButtonClicked:(UIBarButtonItem *)sender {
    if (self.needsToDownloadDataToDisplayActionButtonActionSheet) {
        self.actionButtonActive = YES;
        [self downloadDataToDisplayActionButton];
    } else {
        self.actionButtonActive = NO;
        UIActionSheet *sheet = self.actionButtonActionSheet;
        sheet.tag = kUIActionButtonActionSheetTag;
        
        [sheet showInView:self.tabBarController.view];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.canDisplayActionButton) {
        self.navigationItem.rightBarButtonItem = self.actionButton;
    }
}

@end
