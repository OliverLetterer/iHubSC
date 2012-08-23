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
    NSString *_directory;
    
    NSString *_repository;
    NSString *_branch;
    NSString *_hash;
}

@property (nonatomic, strong) GHAPITreeV3 *tree;

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *branch;
@property (nonatomic, copy) NSString *hash;

- (id)initWithTreeFile:(GHAPITreeFileV3 *)file repository:(NSString *)repository directory:(NSString *)directory branch:(NSString *)branch;

@end
