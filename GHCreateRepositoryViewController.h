//
//  GHCreateRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHCreateRepositoryViewController, GHAPIRepositoryV3, GHCreateRepositoryTableViewCell;

@protocol GHCreateRepositoryViewControllerDelegate <NSObject>

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHAPIRepositoryV3 *)repository;

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController;

@end


@interface GHCreateRepositoryViewController : GHTableViewController <UITextFieldDelegate> {
@private
    id<GHCreateRepositoryViewControllerDelegate> __weak _delegate;
    GHCreateRepositoryTableViewCell *_createCell;
}

@property (nonatomic, weak) id<GHCreateRepositoryViewControllerDelegate> delegate;
@property (nonatomic, retain) GHCreateRepositoryTableViewCell *createCell;

- (void)cancelButtonClicked:(UIBarButtonItem *)button;
- (void)createButtonClicked:(UIBarButtonItem *)button;

- (void)publicSwitchChanged:(UISwitch *)sender;

- (void)createRepository;

@end
