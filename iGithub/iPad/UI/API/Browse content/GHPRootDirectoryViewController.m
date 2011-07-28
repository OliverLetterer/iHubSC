//
//  GHPRootDirectoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPRootDirectoryViewController.h"


@implementation GHPRootDirectoryViewController

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash {
    if ((self = [super initWithDirectory:nil repository:repository branch:branch hash:hash])) {
        // Custom initialization
        self.title = self.branch;
        self.isDownloadingEssentialData = YES;
        [GHRepository filesOnRepository:self.repository 
                                 branch:self.branch 
                      completionHandler:^(GHDirectory *rootDirectory, NSError *error) {
                          self.isDownloadingEssentialData = NO;
                          if (error) {
                              [self handleError:error];
                          } else {
                              self.directory = rootDirectory;
                              self.title = self.branch;
                              if (self.isViewLoaded) {
                                  [self.tableView reloadData];
                              }
                          }
                      }];
    }
    return self;
}

@end
