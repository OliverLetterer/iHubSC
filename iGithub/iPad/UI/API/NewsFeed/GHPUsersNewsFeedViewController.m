//
//  GHPUsersNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPUsersNewsFeedViewController.h"


@implementation GHPUsersNewsFeedViewController

@synthesize username=_username;

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super init])) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - Downloading

- (void)downloadNewsFeed {
    [GHAPIEventV3 eventsByUserNamed:self.username
                               page:1 
                  completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                      self.isDownloadingEssentialData = NO;
                      
                      if (error) {
                          [self handleError:error];
                      } else {
                          self.events = array;
                      }
                  }];
}

#pragma mark - Memory management


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
