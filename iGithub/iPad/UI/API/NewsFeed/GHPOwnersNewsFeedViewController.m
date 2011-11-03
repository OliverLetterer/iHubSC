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
    [GHAPIEventV3 eventsForAuthenticatedUserOnPage:1 
                                 completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                     self.isDownloadingEssentialData = NO;
                                     
                                     if (error) {
                                         [self handleError:error];
                                     } else {
                                         self.events = array;
                                         [self serializeEvents:array];
                                     }
                                 }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.events) {
        self.events = [self loadSerializedEvents];
    }
    
    if (self.events) {
        self.isDownloadingEssentialData = NO;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectEvent:(GHAPIEventV3 *)event atIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (event.type == GHAPIEventTypeV3WatchEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // watched my repo, show the user
            viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // show me the repo that he is following
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    } else if (event.type == GHAPIEventTypeV3FollowEvent) {
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        if ([followEvent.user.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // started following me, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:followEvent.actor.login];
        } else {
            // following someone else, show me the target
            viewController = [[GHPUserViewController alloc] initWithUsername:followEvent.user.login];
        }
    } else if (event.type == GHAPIEventTypeV3ForkEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // forked my repository, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end







NSString *const GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName = @"de.olettere.lastKnownNewsFeedV3.plist";

@implementation GHPOwnersNewsFeedViewController (GHPOwnersNewsFeedViewControllerSerializaiton)

- (void)serializeEvents:(NSArray *)events
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName];
    
    [NSKeyedArchiver archiveRootObject:events toFile:filePath];
}

- (NSArray *)loadSerializedEvents
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:GHPOwnersNewsFeedViewControllerNewsFeedSerializationFileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
