//
//  GHCreateRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHCreateRepositoryViewController, GHRepository, GHCreateRepositoryTableViewCell;

@protocol GHCreateRepositoryViewControllerDelegate <NSObject>

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHRepository *)repository;

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController;

@end



@interface GHCreateRepositoryViewController : GHTableViewController <UITextFieldDelegate> {
@private
    id<GHCreateRepositoryViewControllerDelegate> _delegate;
    GHCreateRepositoryTableViewCell *_createCell;
}

@property (nonatomic, assign) id<GHCreateRepositoryViewControllerDelegate> delegate;
@property (nonatomic, retain) GHCreateRepositoryTableViewCell *createCell;

- (void)cancelButtonClicked:(UIBarButtonItem *)button;
- (void)createButtonClicked:(UIBarButtonItem *)button;

- (void)publicSwitchChanged:(UISwitch *)sender;

- (void)createRepository;

@end
