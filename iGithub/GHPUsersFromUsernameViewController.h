//
//  GHPFollowingUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPUsersViewController.h"

@interface GHPUsersFromUsernameViewController : GHPUsersViewController {
@private
    NSString *_username;
}

@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

@end
