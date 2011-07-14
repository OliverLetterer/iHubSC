//
//  GHViewDirectoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewDirectoryViewController.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"
#import "GHViewCloudFileViewController.h"

@implementation GHViewDirectoryViewController

@synthesize directory=_directory, repository=_repository, branch=_branch, hash=_hash;

- (void)setDirectory:(GHDirectory *)directory {
    if (directory != _directory) {
        [_directory release];
        _directory = [directory retain];
        
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

- (void)dealloc {
    [_directory release];
    [_repository release];
    [_branch release];
    [_hash release];
    [super dealloc];
}

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
    
    UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        // dir
        GHDirectory *directory = [self.directory.directories objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@/", directory.lastNameComponent];
//        cell.imageView.image = [UIImage imageNamed:@"GHFolder.png"];
    } else if (indexPath.section == 1) {
        GHFile *file = [self.directory.files objectAtIndex:indexPath.row];
        cell.textLabel.text = file.name;
//        cell.imageView.image = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // wow, another directory
        GHDirectory *directory = [self.directory.directories objectAtIndex:indexPath.row];
        
        GHViewDirectoryViewController *dirViewController = [[[GHViewDirectoryViewController alloc] initWithDirectory:directory 
                                                                                                          repository:self.repository 
                                                                                                              branch:self.branch
                                                                                                                hash:self.hash]
                                                            autorelease];
        [self.navigationController pushViewController:dirViewController animated:YES];
    } else if (indexPath.section == 1) {
        // wow a file, show this baby
        GHFile *file = [self.directory.files objectAtIndex:indexPath.row];
        
        GHViewCloudFileViewController *fileViewController = [[[GHViewCloudFileViewController alloc] initWithRepository:self.repository 
                                                                                                                  tree:self.hash 
                                                                                                              filename:file.name 
                                                                                                           relativeURL:self.directory.name]
                                                             autorelease];
        [self.navigationController pushViewController:fileViewController animated:YES];
    }
}

@end
