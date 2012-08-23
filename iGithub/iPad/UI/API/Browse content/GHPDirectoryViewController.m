//
//  GHPDirectoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDirectoryViewController.h"
#import "GHViewCloudFileViewController.h"
#import "UIColor+GithubUI.h"

@implementation GHPDirectoryViewController
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
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
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

#pragma mark - Memory management


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // directories
        return _tree.directories.count;
    } else if (section == 1) {
        return _tree.files.count;;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
    
    if (indexPath.section == 0) {
        // directory
        GHAPITreeFileV3 *directory = [_tree.directories objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@/", directory.path];
        cell.imageView.image = [UIImage imageNamed:@"GHFolder.png"];
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
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == 0) {
        // wow, another directory
        GHAPITreeFileV3 *directory = [_tree.directories objectAtIndex:indexPath.row];
        
        viewController = [[GHPDirectoryViewController alloc] initWithTreeFile:directory repository:_repository directory:[_directory stringByAppendingPathComponent:directory.path] branch:_branch];
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
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
