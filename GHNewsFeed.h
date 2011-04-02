//
//  GHNewsFeed.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHNewsFeed : NSObject {
    NSArray *_items;
}

+ (void)privateNewsFeedForUserNamed:(NSString *)username 
                           password:(NSString *)password 
                  completionHandler:(void(^)(GHNewsFeed *feed, NSError *error))handler;

+ (void)usersNewsFeedForUserNamed:(NSString *)username 
                         password:(NSString *)password 
                completionHandler:(void(^)(GHNewsFeed *feed, NSError *error))handler;

@property (nonatomic, retain) NSArray *items; // contains GHNewsFeedItem's

- (id)initWithRawArray:(NSArray *)rawArray;

@end
