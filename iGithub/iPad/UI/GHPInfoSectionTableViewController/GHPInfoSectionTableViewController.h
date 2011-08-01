//
//  GHPInfoSectionTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPInfoTableViewCell.h"

@interface GHPInfoSectionTableViewController : GHTableViewController <GHPInfoTableViewCellDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate> {
@protected
    GHPInfoTableViewCell *_infoCell;
    UIPopoverController *_currentPopoverController;
}

@property (nonatomic, readonly) GHPInfoTableViewCell *infoCell;

// action Button
@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;     // overwrite
@property (nonatomic, readonly) BOOL needsToDownloadDataToDisplayActionButtonActionSheet;     // overwrite
@property (nonatomic, readonly) BOOL canDisplayActionButton;                // overwrite

@property (nonatomic, assign, getter=isActionButtonActive) BOOL actionButtonActive;

- (void)downloadDataToDisplayActionButton;      // overwrite
- (void)didDownloadDataToDisplayActionButton;
- (void)failedToDownloadDataToDisplayActionButtonWithError:(NSError *)error;

- (void)presentViewControllerFromActionButton:(UIViewController *)viewController detatchNavigationController:(BOOL)detatchNavigationController animated:(BOOL)animted;

@end
