//
//  GHPUsersViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPUsersViewController : GHTableViewController {
@private
    NSMutableArray *_users;
}

@property (nonatomic, retain) NSMutableArray *users;

@end
