//
//  GHPRepositoriesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPRepositoriesViewController : GHTableViewController {
@private
    NSMutableArray *_repositories;
    NSString *_username;
}

@property (nonatomic, retain) NSMutableArray *repositories;
@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

- (void)cacheRepositoriesHeights;

@end
