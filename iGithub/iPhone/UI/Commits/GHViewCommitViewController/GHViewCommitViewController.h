//
//  GHViewCommitViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHTableViewController.h"

@interface GHViewCommitViewController : GHTableViewController {
@private
    NSString *_repository;
    NSString *_commitID;
    GHCommit *_commit;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *commitID;
@property (nonatomic, retain) GHCommit *commit;

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID;

- (void)downloadCommitData;

@end
