//
//  GHViewDirectoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewDirectoryViewController.h"
#import "GHTableViewCellWithLinearGradientBackgroundView.h"
#import "GHViewCloudFileViewController.h"
#import "SVModalWebViewController.h"
#import "UIColor+GithubUI.h"

@implementation GHViewDirectoryViewController
@synthesize repository=_repository, branch=_branch, hash=_hash;

- (void)setTree:(GHAPITreeV3 *)tree
{
    if (tree != _tree) {
        _tree = tree;
        
        [self.tableView reloadData];
    }
}

#pragma mark - Initialization

- (id)initWithTreeFile:(GHAPITreeFileV3 *)file repository:(NSString *)repository directory:(NSString *)directory branch:(NSString *)branch
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _repository = repository;
        _directory = directory;
        _branch = branch;
        self.title = file.path;
        
        self.isDownloadingEssentialData = YES;
        [GHAPITreeV3 contentOfBranch:file.SHA onRepository:repository completionHandler:^(GHAPITreeV3 *tree, NSError *error) {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // directories
        return _tree.directories.count;
    } else if (section == 1) {
        return _tree.files.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
    
    GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        // dir
        GHAPITreeFileV3 *directory = [_tree.directories objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@/", directory.path];
        cell.imageView.image = [UIImage imageNamed:@"GHFolder.png"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        GHAPITreeFileV3 *file = [_tree.files objectAtIndex:indexPath.row];
        
        cell.textLabel.text = file.path;
        NSString *fileExtension = [[file.path componentsSeparatedByString:@"."] lastObject];
        NSString *imageName = [NSString stringWithFormat:@"GHFile_%@.png", fileExtension];
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) {
            image = [UIImage imageNamed:@"GHFile.png"];
        }
        cell.imageView.image = image;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // wow, another directory
        GHAPITreeFileV3 *directory = [_tree.directories objectAtIndex:indexPath.row];
        
        GHViewDirectoryViewController *dirViewController = [[GHViewDirectoryViewController alloc] initWithTreeFile:directory
                                                                                                        repository:_repository
                                                                                                         directory:[_directory stringByAppendingPathComponent:directory.path]
                                                                                                            branch:_branch];
        [self.navigationController pushViewController:dirViewController animated:YES];
    } else if (indexPath.section == 1) {
        // wow a file, show this baby
        GHAPITreeFileV3 *file = [_tree.files objectAtIndex:indexPath.row];
        
        // https://github.com/OliverLetterer/SVSegmentedControl/blob/master/LICENSE.txt
        NSString *URLString = [NSString stringWithFormat:@"https://github.com"];
        URLString = [URLString stringByAppendingPathComponent:self.repository];
        URLString = [URLString stringByAppendingPathComponent:@"blob"];
        URLString = [URLString stringByAppendingPathComponent:_branch];
        URLString = [URLString stringByAppendingPathComponent:_directory];
        URLString = [URLString stringByAppendingPathComponent:file.path];
        NSURL *URL = [NSURL URLWithString:URLString];
        
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
        webViewController.webDelegate = self;
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:webViewController animated:YES completion:nil];
    }
}

#pragma mark - SVModalWebViewControllerDelegate

- (void)modalWebViewControllerIsDone:(SVModalWebViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_directory forKey:@"directory"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_hash forKey:@"hash"];
    [encoder encodeObject:_tree forKey:@"tree"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _directory = [decoder decodeObjectForKey:@"directory"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _hash = [decoder decodeObjectForKey:@"hash"];
        _tree = [decoder decodeObjectForKey:@"tree"];
    }
    return self;
}

@end
