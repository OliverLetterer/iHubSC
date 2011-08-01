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
    if ((self = [super initWithDirectory:nil repository:repository branch:branch hash:hash])) {
        // Custom initialization
        self.title = self.branch;
        [GHRepository filesOnRepository:self.repository 
                                 branch:self.branch 
                      completionHandler:^(GHDirectory *rootDirectory, NSError *error) {
                          if (error) {
                              [self handleError:error];
                          } else {
                              self.directory = rootDirectory;
                              self.title = self.branch;
                              [self.tableView reloadData];
                          }
                      }];
    }
    return self;
}

@end
