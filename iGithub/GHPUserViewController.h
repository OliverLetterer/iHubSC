//
//  GHPUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPTableViewController.h"
#import "GHPUserInfoTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface GHPUserViewController : GHPTableViewController <GHPUserInfoTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    GHAPIUserV3 *_user;
    NSString *_username;
    
    GHPUserInfoTableViewCell *_userInfoCell;
    
    BOOL _hasFollowingData;
    BOOL _isFollowingUser;
}

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, readonly) NSString *userDetailInfoString;

@property (nonatomic, readonly) BOOL isAdminsitrativeUser;
@property (nonatomic, readonly) BOOL canDisplayActionButton;

@property (nonatomic, retain) GHPUserInfoTableViewCell *userInfoCell;

@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;

- (id)initWithUsername:(NSString *)username;

@end
