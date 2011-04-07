//
//  GHRepositoriesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHCreateRepositoryViewController.h"

@interface GHRepositoriesViewController : GHTableViewController <GHCreateRepositoryViewControllerDelegate> {
@private
    NSArray *_repositoriesArray;
    NSString *_username;
}

#warning support multiple pages of repos

@property (nonatomic, retain) NSArray *repositoriesArray;
@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

- (void)downloadRepositories;

- (void)cacheHeightForTableView;

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button;

@end
