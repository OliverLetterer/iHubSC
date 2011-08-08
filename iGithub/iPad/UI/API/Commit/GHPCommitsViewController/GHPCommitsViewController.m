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

@implementation GHPCommitsViewController

@synthesize repository=_repository, branchHash=_branchHash;
@synthesize pushPayload=_pushPayload;

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

- (id)initWithRepository:(NSString *)repository pushPayload:(GHPushPayload *)pushPayload {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repository = repository;
        _contentType = GHPCommitsViewControllerContentTypePushPayload;
        self.pushPayload = pushPayload;
        [self setDataArray:[self.pushPayload.commits mutableCopy] nextPage:GHAPIPaginationNextPageNotFound];
    }
    return self;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_contentType == GHPCommitsViewControllerContentTypePushPayload) {
        static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
        
        GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHCommitMessage *message = [self.dataArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ - %@", @""), message.name, message.head];
        cell.detailTextLabel.text = message.message;
        cell.imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
        
        GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.row];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:commit.committer.avatarURL];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", commit.committer.login, commit.SHA];
        cell.detailTextLabel.text = commit.message;
        
        // Configure the cell...
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (_contentType == GHPCommitsViewControllerContentTypePushPayload) {
        GHCommitMessage *message = [self.dataArray objectAtIndex:indexPath.row];
        
        viewController = [[GHPCommitViewController alloc] initWithRepository:self.repository 
                                                                     commitID:message.head];
    } else {
        GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.row];
        
        viewController = [[GHPCommitViewController alloc] initWithRepository:self.repository 
                                                                     commitID:commit.SHA];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = UITableViewAutomaticDimension;
        
        if (_contentType == GHPCommitsViewControllerContentTypePushPayload) {
            GHCommitMessage *commit = obj;
            height = [GHPImageDetailTableViewCell heightWithContent:commit.message];
        } else {
            GHAPICommitV3 *commit = obj;
            height = [GHPImageDetailTableViewCell heightWithContent:commit.message];
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branchHash forKey:@"branchHash"];
    [encoder encodeObject:_pushPayload forKey:@"pushPayload"];
    [encoder encodeInt:_contentType forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _branchHash = [decoder decodeObjectForKey:@"branchHash"];
        _pushPayload = [decoder decodeObjectForKey:@"pushPayload"];
        _contentType = [decoder decodeIntForKey:@"contentType"];
    }
    return self;
}

@end
