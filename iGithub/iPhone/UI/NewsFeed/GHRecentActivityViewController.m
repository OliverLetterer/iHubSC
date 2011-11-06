//
//  GHRecentActivityViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRecentActivityViewController.h"
#import "GithubAPI.h"

@implementation GHRecentActivityViewController
@synthesize username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    _username = [username copy];
    
    [self pullToReleaseTableViewReloadData];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [self init])) {
        self.username = username;
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Recent activity", @"");
        self.pullToReleaseEnabled = NO;
    }
    return self;
}

//#pragma mark - Memory management
//
//
//#pragma mark - instance methods
//
//- (void)pullToReleaseTableViewReloadData {
//    [super pullToReleaseTableViewReloadData];
//    if (!self.events) {
//        self.isDownloadingEssentialData = YES;
//    }
//    
//    [GHAPIEventV3 eventsForUserNamed:_username 
//                                page:1 
//                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
//                       self.isDownloadingEssentialData = NO;
//                       
//                       if (error) {
//                           [self handleError:error];
//                       } else {
//                           self.events = array;
//                       }
//                       
//                       [self pullToReleaseTableViewDidReloadData];
//                   }];
//}

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString
{
    [GHAPIEventV3 eventsByUserNamed:_username 
           sinceLastEventDateString:lastKnownEventDateString 
                  completionHandler:^(NSArray *events, NSError *error) {
                      if (error) {
                          [self handleError:error];
                      } else {
                          [self appendNewEvents:events];
                      }
                      
                      self.isDownloadingEssentialData = NO;
                      [self pullToReleaseTableViewDidReloadData];
                  }];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_username forKey:@"username"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _username = [decoder decodeObjectForKey:@"username"];
    }
    return self;
}

@end
