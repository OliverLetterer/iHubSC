//
//  GHActionButtonTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 31.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

extern NSInteger const kUIActionButtonActionSheetTag;

@interface GHActionButtonTableViewController : GHTableViewController <UIActionSheetDelegate> {
@private
    UIBarButtonItem *_actionButton;
    UIBarButtonItem *_loadingActionButton;
}

@property (nonatomic, readonly) UIBarButtonItem *actionButton;
@property (nonatomic, readonly) UIBarButtonItem *loadingActionButton;

// action Button
@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;     // overwrite
@property (nonatomic, readonly) BOOL needsToDownloadDataToDisplayActionButtonActionSheet;     // overwrite
@property (nonatomic, readonly) BOOL canDisplayActionButton;                // overwrite

@property (nonatomic, assign, getter=isActionButtonActive) BOOL actionButtonActive;

- (void)downloadDataToDisplayActionButton;      // overwrite
- (void)didDownloadDataToDisplayActionButton;
- (void)failedToDownloadDataToDisplayActionButtonWithError:(NSError *)error;

- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end
