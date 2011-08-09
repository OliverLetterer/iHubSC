//
//  GHActionButtonTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHActionButtonTableViewController.h"
#import "UIBarButtonItem+GHEmpty.h"
#import "UIColor+GithubUI.h"

NSInteger const kUIActionButtonActionSheetTag = 549532;

NSInteger const kUIActionButtonActivityIndicatorView = 123908;

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
        UIBarButtonItem *emptyButton = [UIBarButtonItem emptyBarButtonItemWithWidth:43.0f tintColor:[UIColor defaultNavigationBarTintColor] ];
        
        UIView *wrapperView = emptyButton.customView;
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.tag = kUIActionButtonActivityIndicatorView;
        [wrapperView addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        activityIndicatorView.center = CGPointMake(CGRectGetMidX(wrapperView.bounds), CGRectGetMidY(wrapperView.bounds));
        _loadingActionButton = emptyButton;
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
    if (actionButtonActive != self.isActionButtonActive) {
        if (actionButtonActive) {
            self.navigationItem.rightBarButtonItem = self.loadingActionButton;
            UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.loadingActionButton.customView viewWithTag:kUIActionButtonActivityIndicatorView];
            
            activityIndicatorView.transform = CGAffineTransformMakeScale(0.05f, 0.05f);
            [UIView animateWithDuration:0.25f animations:^(void) {
                activityIndicatorView.transform = CGAffineTransformIdentity;
            }];
        } else {
            self.navigationItem.rightBarButtonItem = self.actionButton;
        }
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
        
        if (self.tabBarController.view) {
            [sheet showInView:self.tabBarController.view];
        }
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
