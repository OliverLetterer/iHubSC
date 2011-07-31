//
//  GHPRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPInfoTableViewCell.h"
#import "GHPInfoSectionTableViewController.h"
#import "GHCreateIssueTableViewController.h"

@interface GHPRepositoryViewController : GHPInfoSectionTableViewController <GHCreateIssueTableViewControllerDelegate, NSCoding> {
@private
    NSString *_repositoryString;
    GHAPIRepositoryV3 *_repository;
    NSString *_deleteToken;
    NSMutableArray *_organizations;
    
    BOOL _hasWatchingData;
    BOOL _isWatchingRepository;
    
    NSMutableArray *_labels;
    NSMutableArray *_branches;
}

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;
@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, readonly) NSString *metaInformationString;
@property (nonatomic, retain) NSMutableArray *organizations;
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *branches;

@property (nonatomic, readonly) BOOL canAdministrateRepository;

@property (nonatomic, readonly) UIActionSheet *actionButtonActionSheet;

- (id)initWithRepositoryString:(NSString *)repositoryString;

- (void)organizationsActionSheetDidSelectOrganizationAtIndex:(NSUInteger)index;

@end
