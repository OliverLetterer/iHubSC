//
//  GHViewDirectoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHTableViewController.h"
#import "SVModalWebViewController.h"

@interface GHViewDirectoryViewController : GHTableViewController <SVModalWebViewControllerDelegate> {
@private
    GHDirectory *_directory;
    
    NSString *_repository;
    NSString *_branch;
    NSString *_hash;
}

@property (nonatomic, retain) GHDirectory *directory;
@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *branch;
@property (nonatomic, copy) NSString *hash;

- (id)initWithDirectory:(GHDirectory *)directory repository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash;

@end
