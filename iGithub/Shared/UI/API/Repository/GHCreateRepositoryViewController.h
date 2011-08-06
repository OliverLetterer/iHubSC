//
//  GHCreateRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHCreateContentViewController.h"

@class GHCreateRepositoryViewController, GHAPIRepositoryV3, GHCreateRepositoryTableViewCell;

@protocol GHCreateRepositoryViewControllerDelegate <NSObject>

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHAPIRepositoryV3 *)repository;

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController;

@end


@interface GHCreateRepositoryViewController : GHCreateContentViewController <UITextFieldDelegate> {
@private
    id<GHCreateRepositoryViewControllerDelegate> __weak _delegate;
}

@property (nonatomic, weak) id<GHCreateRepositoryViewControllerDelegate> delegate;

- (void)publicSwitchChanged:(id)sender;

@end
