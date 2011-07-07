//
//  GHPDataArrayViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDataArrayViewController.h"


@implementation GHPDataArrayViewController

@synthesize dataArray=_dataArray;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Data available", @"");
}

- (void)setDataArray:(NSMutableArray *)dataArray nextPage:(NSUInteger)nextPage {
    if (dataArray != _dataArray) {
        [_dataArray release], _dataArray = [dataArray retain];
        
        self.isDownloadingEssentialData = NO;
        [self cacheDataArrayHeights];
        
        [self setNextPage:nextPage forSection:0];
        
        if (dataArray != nil && dataArray.count == 0) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                                  message:self.emptyArrayErrorMessage 
                                                                                 delegate:nil 
                                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                        otherButtonTitles:nil]
                                                       autorelease];
            [alert show];
            [self.advancedNavigationController popViewController:self];
        }
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (void)appendDataFromArray:(NSMutableArray *)array nextPage:(NSUInteger)nextPage {
    [self.dataArray addObjectsFromArray:array];
    [self setNextPage:nextPage forSection:0];
    [self cacheDataArrayHeights];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
        self.isDownloadingEssentialData = YES;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_dataArray release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.dataArray) {
        return 0;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isHeightCachedForRowAtIndexPath:indexPath]) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    
    return UITableViewAutomaticDimension;
}

#pragma mark - Height caching

- (void)cacheDataArrayHeights {
    
}

@end
