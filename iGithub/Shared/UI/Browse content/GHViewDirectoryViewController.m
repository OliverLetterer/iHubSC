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

@implementation GHViewDirectoryViewController

@synthesize directory=_directory, repository=_repository, branch=_branch, hash=_hash;

- (void)setDirectory:(GHDirectory *)directory {
    if (directory != _directory) {
        _directory = directory;
        
        self.title = _directory.lastNameComponent;
    }
}

#pragma mark - Initialization

- (id)initWithDirectory:(GHDirectory *)directory repository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.directory = directory;
        self.repository = repository;
        self.branch = branch;
        self.hash = hash;
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
        return [self.directory.directories count];
    } else if (section == 1) {
        return [self.directory.files count];
    }
    // Return the number of rows in the section.
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
        GHDirectory *directory = [self.directory.directories objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@/", directory.lastNameComponent];
        cell.imageView.image = [UIImage imageNamed:@"GHFolder.png"];
    } else if (indexPath.section == 1) {
        GHFile *file = [self.directory.files objectAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
        NSString *fileExtension = [[file.name componentsSeparatedByString:@"."] lastObject];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // wow, another directory
        GHDirectory *directory = [self.directory.directories objectAtIndex:indexPath.row];
        
        GHViewDirectoryViewController *dirViewController = [[GHViewDirectoryViewController alloc] initWithDirectory:directory 
                                                                                                          repository:self.repository 
                                                                                                              branch:self.branch
                                                                                                                hash:self.hash];
        [self.navigationController pushViewController:dirViewController animated:YES];
    } else if (indexPath.section == 1) {
        // wow a file, show this baby
        GHFile *file = [self.directory.files objectAtIndex:indexPath.row];
        
        GHViewCloudFileViewController *fileViewController = [[GHViewCloudFileViewController alloc] initWithRepository:self.repository 
                                                                                                                  tree:self.hash 
                                                                                                              filename:file.name 
                                                                                                           relativeURL:self.directory.name];
        [self.navigationController pushViewController:fileViewController animated:YES];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_directory forKey:@"directory"];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_hash forKey:@"hash"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _directory = [decoder decodeObjectForKey:@"directory"];
        _repository = [decoder decodeObjectForKey:@"repository"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _hash = [decoder decodeObjectForKey:@"hash"];
    }
    return self;
}

@end
