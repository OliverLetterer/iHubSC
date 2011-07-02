//
//  GHPCommitsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPCommitsViewController : GHTableViewController {
@private
    NSString *_repository;
    NSString *_branchHash;
    
    NSMutableArray *_commits;
}

@property (nonatomic, readonly) NSString *repository;
@property (nonatomic, readonly) NSString *branchHash;

@property (nonatomic, retain) NSMutableArray *commits;

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash;

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash;
- (void)cacheCommitsHeights;

@end
