//
//  GHAuthenticationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCellWithTextField.h"

@class GHAuthenticationViewController, GHUser;

@protocol GHAuthenticationViewControllerDelegate <NSObject>

- (void)authenticationViewController:(GHAuthenticationViewController *)authenticationViewController didAuthenticateUser:(GHUser *)user;

@end



@interface GHAuthenticationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewCellWithTextFieldDelegate> {
    id<GHAuthenticationViewControllerDelegate> _delegate;
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_imageView;
    IBOutlet UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

@property (nonatomic, assign) id<GHAuthenticationViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@end
