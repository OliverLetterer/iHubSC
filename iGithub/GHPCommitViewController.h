//
//  GHPCommitViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPCommitViewController : GHTableViewController {
@private
    NSString *_repository;
    NSString *_commitID;
    
    GHCommit *_commit;
}

@property (nonatomic, copy, readonly) NSString *repository;
@property (nonatomic, copy, readonly) NSString *commitID;
- (void)setRepository:(NSString *)repository commitID:(NSString *)commitID;

@property (nonatomic, retain) GHCommit *commit;

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID;

@end
