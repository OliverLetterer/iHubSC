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

@interface GHPInfoSectionTableViewController : GHTableViewController <GHPInfoTableViewCellDelegate, UIActionSheetDelegate> {
@private
    GHPInfoTableViewCell *_infoCell;
}

@property (nonatomic, readonly) GHPInfoTableViewCell *infoCell;

// action Button
@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;
@property (nonatomic, readonly) BOOL canDisplayActionButtonActionSheet;
@property (nonatomic, readonly) BOOL canDisplayActionButton;

@property (nonatomic, assign, getter = isActionButtonActive) BOOL actionButtonActive;

- (void)downloadDataToDisplayActionButton;
- (void)didDownloadDataToDisplayActionButton;
- (void)failedToDownloadDataToDisplayActionButtonWithError:(NSError *)error;

@end
