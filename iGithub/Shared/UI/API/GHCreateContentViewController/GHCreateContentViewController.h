//
//  GHCreateContentViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHCreateContentViewController : GHTableViewController {
    UIBarButtonItem *_loadingButton;
    UIBarButtonItem *_saveButton;
    UIBarButtonItem *_cancelButton;
}

@property (nonatomic, readonly) UIBarButtonItem *loadingButton;
@property (nonatomic, readonly) UIBarButtonItem *saveButton;
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;


- (void)saveButtonClicked:(UIBarButtonItem *)sender;
- (void)cancelButtonClicked:(UIBarButtonItem *)cancelButton;

@end
