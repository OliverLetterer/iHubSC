//
//  GHPOwnersNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOwnersNewsFeedViewController.h"
#import "GHPUserViewController.h"
#import "GHPRepositoryViewController.h"

@implementation GHPOwnersNewsFeedViewController

#pragma mark - initialization

- (id)init {
    if (self = [super init]) {
        self.reloadDataOnApplicationWillEnterForeground = YES;
        self.reloadDataIfNewUserGotAuthenticated = YES;
    }
    return self;
}

#pragma mark - Downloading

- (void)downloadNewsFeed {
    [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
            [self serializeNewsFeed:feed];
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.newsFeed) {
        self.newsFeed = [self loadSerializedNewsFeed];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    UIViewController *viewController = nil;
    
    if (item.payload.type == GHPayloadWatchEvent) {
        if ([item.repository.fullName hasPrefix:[GHAPIAuthenticationManager sharedInstance].username]) {
            // watched my repo, show the user
            viewController = [[GHPUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // show me the repo that he is following
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        }
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        if ([payload.target.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].username]) {
            // started following me, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // following someone else, show me the target
            viewController = [[GHPUserViewController alloc] initWithUsername:payload.target.login];
        }
    } else if (item.payload.type == GHPayloadForkEvent) {
        if ([item.repository.fullName hasPrefix:[GHAPIAuthenticationManager sharedInstance].username]) {
            // forked my repository, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end







NSString *const GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName = @"de.olettere.lastKnownNewsFeed.plist";

@implementation GHPOwnersNewsFeedViewController (GHPOwnersNewsFeedViewControllerSerializaiton)

- (void)serializeNewsFeed:(GHNewsFeed *)newsFeed {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName];
    
    [NSKeyedArchiver archiveRootObject:newsFeed toFile:filePath];
}

- (GHNewsFeed *)loadSerializedNewsFeed {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
