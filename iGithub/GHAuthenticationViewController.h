//
//  GHAuthenticationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCellWithTextField.h"

NSString *const GHAuthenticationViewControllerDidAuthenticateUserNotification;

@class GHAuthenticationViewController, GHUserV3;

@protocol GHAuthenticationViewControllerDelegate <NSObject>

- (void)authenticationViewController:(GHAuthenticationViewController *)authenticationViewController didAuthenticateUser:(GHUserV3 *)user;

@end



@interface GHAuthenticationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewCellWithTextFieldDelegate> {
    id<GHAuthenticationViewControllerDelegate> _delegate;
    IBOutlet UITableView *_tableView;
    IBOutlet UIImageView *_imageView;
    IBOutlet UIActivityIndicatorView *_activityIndicatorView;
    
    UIImageView *_borderImageView;
    UIImageView *_glossImageView;
}

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

@property (nonatomic, assign) id<GHAuthenticationViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

+ (BOOL)isOneAuthenticationViewControllerActive;

- (void)keyboardWillShowCallback:(NSNotification *)notification;
- (void)keyboardWillHideCallback:(NSNotification *)notification;

@end
