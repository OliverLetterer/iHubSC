//
//  GHViewREADMEViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewREADMEViewController.h"
#import "GithubAPI.h"
#import "ANAdvancedNavigationController.h"

@implementation GHViewREADMEViewController
@synthesize branchHash=_branchHash;

#pragma mark - setters and getters

- (void)popWithError:(NSError *)error {
    if (error) {
        [self handleError:error];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.advancedNavigationController popViewController:self animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super init])) {
        self.repository = repository;
        
        // 1: download repository
        [GHAPIRepositoryV3 repositoryNamed:repository 
                     withCompletionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                         if (error) {
                             [self popWithError:error];
                         } else {
                             NSString *masterBranch = repository.masterBranch ? repository.masterBranch : @"master";
                             
                             // 2: download branchHash
                             [GHAPIRepositoryV3 branchesOnRepository:repository.fullRepositoryName page:1 
                                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                                       if (error) {
                                                           [self popWithError:error];
                                                       } else {
                                                           __block NSString *branchHash = nil;
                                                           [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                               GHAPIRepositoryBranchV3 *branch = obj;
                                                               if ([branch.name isEqualToString:masterBranch]) {
                                                                   branchHash = branch.ID;
                                                               }
                                                           }];
                                                           
                                                           // 3: download content of tree
                                                           [GHAPITreeV3 contentOfBranch:branchHash onRepository:repository.fullRepositoryName 
                                                                      completionHandler:^(GHAPITreeV3 *tree, NSError *error) {
                                                                          if (error) {
                                                                              [self popWithError:error];
                                                                          } else {
                                                                              __block NSString *READMEFileName = nil;
                                                                              __block BOOL hasMarkdown = NO;
                                                                              NSArray *markdownExtensions = [NSArray arrayWithObjects:@".md", @".markdown", @".mdown", nil];
                                                                              [tree.content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                  GHAPITreeFileV3 *file = obj;
                                                                                  if ([file.path rangeOfString:@"readme" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                                                                                      if (!hasMarkdown) {
                                                                                          for (NSString *extension in markdownExtensions) {
                                                                                              if ([file.path rangeOfString:extension options:NSCaseInsensitiveSearch].location != NSNotFound) {
                                                                                                  READMEFileName = file.path;
                                                                                                  hasMarkdown = YES;
                                                                                              }
                                                                                          }
                                                                                          if (!hasMarkdown) {
                                                                                              READMEFileName = file.path;
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              }];
                                                                              self.filename = READMEFileName;
                                                                              
                                                                              // 4: download the metadata
                                                                              [GHFileMetaData metaDataOfFile:READMEFileName 
                                                                                               atRelativeURL:@"" 
                                                                                                onRepository:repository.fullRepositoryName 
                                                                                                        tree:branchHash 
                                                                                           completionHandler:^(GHFileMetaData *metaData, NSError *error) {
                                                                                               if (error) {
                                                                                                   [self popWithError:error];
                                                                                               } else {
                                                                                                   self.metadata = metaData;
                                                                                               }
                                                                                           }];
                                                                          }
                                                                      }];
                                                       }
                                                   }];
                         }
                     }];
    }
    return self;
}

@end
