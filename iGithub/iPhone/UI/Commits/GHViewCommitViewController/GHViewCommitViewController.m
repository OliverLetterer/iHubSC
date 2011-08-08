//
//  GHViewCommitViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewCommitViewController.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "GHCommitDiffViewController.h"
#import "GHViewCloudFileViewController.h"

@implementation GHViewCommitViewController

@synthesize repository=_repository, commitID=_commitID, commit=_commit, branchHash=_branchHash;

#pragma mark - setters and getters

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repository = repository;
        self.commitID = commitID;
        self.title = NSLocalizedString(@"Commit", @"");
        self.isDownloadingEssentialData = YES;
        [self downloadCommitData];
    }
    return self;
}

#pragma mark - instance methods

- (void)downloadCommitData {
    [GHAPITreeV3 treeOfCommit:self.commitID onRepository:self.repository completionHandler:^(GHAPITreeV3 *tree, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.branchHash = tree.SHA;
            
            [GHCommit commit:self.commitID onRepository:self.repository completionHandler:^(GHCommit *commit, NSError *error) {
                self.isDownloadingEssentialData = NO;
                if (error) {
                    [self handleError:error];
                } else {
                    self.commit = commit;
                    
                    if (self.isViewLoaded) {
                        [self.tableView reloadData];
                    }
                }
            }];
        }
    }];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return YES;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == 0) {
        cell.textLabel.text = NSLocalizedString(@"Added", @"");
    } else if (section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Removed", @"");
    } else if (section == 2) {
        cell.textLabel.text = NSLocalizedString(@"Modified", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.commit) {
        return 0;
    }
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger countArray = 0;
    if (section == 0) {
        countArray = [self.commit.added count];
    } else if (section == 1) {
        countArray = [self.commit.removed count];
    } else if (section == 2) {
        countArray = [self.commit.modified count];
    }
    
    if (countArray > 0) {
        return countArray + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
    
    GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GHCommitFileInformation *info = nil;
    NSString *filename = nil;
    
    if (indexPath.section == 0) {
        filename = [self.commit.added objectAtIndex:indexPath.row-1];
    } else if (indexPath.section == 1) {
        filename = [self.commit.removed objectAtIndex:indexPath.row-1];
    } else if (indexPath.section == 2) {
        info = [self.commit.modified objectAtIndex:indexPath.row-1];
        filename = info.filename;
    }
    
    cell.textLabel.text = filename;
    if (indexPath.section == 2 || indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        GHCommitFileInformation *info = [self.commit.modified objectAtIndex:indexPath.row-1];
        
        GHCommitDiffViewController *diffViewController = [[GHCommitDiffViewController alloc] initWithDiffString:info.diff];
        diffViewController.title = [info.filename lastPathComponent];
        [self.navigationController pushViewController:diffViewController animated:YES];
    } else if (indexPath.section == 0) {
        NSString *filename = [self.commit.added objectAtIndex:indexPath.row-1];
        
        NSString *URL = [filename stringByDeletingLastPathComponent];
        NSString *base = [filename lastPathComponent];
        
        GHViewCloudFileViewController *fileViewController = [[GHViewCloudFileViewController alloc] initWithRepository:self.repository 
                                                                                                                  tree:self.commitID 
                                                                                                              filename:base 
                                                                                                           relativeURL:URL];
        [self.navigationController pushViewController:fileViewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_commitID forKey:@"commitID"];
    [encoder encodeObject:_commit forKey:@"commit"];
    [encoder encodeObject:_branchHash forKey:@"branchHash"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _commitID = [decoder decodeObjectForKey:@"commitID"];
        _commit = [decoder decodeObjectForKey:@"commit"];
        _branchHash = [decoder decodeObjectForKey:@"branchHash"];
    }
    return self;
}

@end
