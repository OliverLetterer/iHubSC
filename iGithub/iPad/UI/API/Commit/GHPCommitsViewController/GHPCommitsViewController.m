//
//  GHPCommitsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCommitsViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPCommitViewController.h"
#import "GHPModalCommitViewController.h"
#import "SVModalWebViewController.h"

@interface GHPCommitsViewController () <SVModalWebViewControllerDelegate>

@end

@implementation GHPCommitsViewController

@synthesize repository=_repository, branchHash=_branchHash;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Commits available", @"");
}

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    _repository = [repository copy];
    _branchHash = [branchHash copy];
    
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setDataArray:array nextPage:nextPage];
                             }
                         }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self appendDataFromArray:array nextPage:nextPage];
                             }
                         }];
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setRepository:repository branchHash:branchHash];
    }
    return self;
}

- (id)initWithRepository:(NSString *)repository commits:(NSArray *)commits {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repository = repository;
        [self setDataArray:commits.mutableCopy nextPage:GHAPIPaginationNextPageNotFound];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 0: the actual commit
    // 1: view in full screen
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.section];
    
    // the actual commit
    static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    [self updateImageView:cell.imageView
              atIndexPath:indexPath
      withAvatarURLString:commit.committer.avatarURL];
    
    NSString *username = commit.committer.login ? commit.committer.login : commit.committer.name;
    if (!username) {
        username = commit.author.login ? commit.author.login : commit.author.name;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", username, commit.SHA];
    cell.detailTextLabel.text = commit.message;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.section];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/commit/%@", _repository, commit.SHA]];
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
    webViewController.webDelegate = self;
    webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:webViewController animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - view lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
}

#pragma mark - height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = UITableViewAutomaticDimension;
        
        GHAPICommitV3 *commit = obj;
        height = [GHPImageDetailTableViewCell heightWithContent:commit.message];
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] ];
        [self cacheHeight:44.0f forRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:idx] ];
    }];
}

#pragma mark - SVModalWebViewControllerDelegate

- (void)modalWebViewControllerIsDone:(SVModalWebViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branchHash forKey:@"branchHash"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _branchHash = [decoder decodeObjectForKey:@"branchHash"];
    }
    return self;
}

@end
