//
//  GHPDataArrayViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDataArrayViewController.h"
#import "ANNotificationQueue.h"

@implementation GHPDataArrayViewController

@synthesize dataArray=_dataArray;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Data available", @"");
}

- (void)setDataArray:(NSMutableArray *)dataArray nextPage:(NSUInteger)nextPage {
    if (dataArray != _dataArray) {
        _dataArray = dataArray;
        
        self.isDownloadingEssentialData = NO;
        [self cacheDataArrayHeights];
        
        [self setNextPage:nextPage forSection:0];
        
        if (dataArray != nil && dataArray.count == 0) {
            [[ANNotificationQueue sharedInstance] detatchErrorNotificationWithTitle:NSLocalizedString(@"Error", @"") errorMessage:self.emptyArrayErrorMessage];
            [self.advancedNavigationController popViewController:self animated:YES];
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_dataArray forKey:@"dataArray"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _dataArray = [decoder decodeObjectForKey:@"dataArray"];
    }
    return self;
}

@end
