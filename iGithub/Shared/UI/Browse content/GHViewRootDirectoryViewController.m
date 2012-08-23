//
//  GHViewRootDirectoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewRootDirectoryViewController.h"


@implementation GHViewRootDirectoryViewController

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        // Custom initialization
        self.title = self.branch;
        self.isDownloadingEssentialData = YES;
        _directory = @"";
        _branch = branch;
        _repository = repository;
        
        [GHAPITreeV3 contentOfBranch:hash onRepository:repository completionHandler:^(GHAPITreeV3 *tree, NSError *error) {
            self.isDownloadingEssentialData = NO;
            if (error) {
                [self handleError:error];
            } else {
                self.tree = tree;
            }
            
        }];
    }
    return self;
}

@end
