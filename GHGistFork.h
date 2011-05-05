//
//  GHGistFork.h
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUser;

@interface GHGistFork : NSObject {
@private
    GHUser *_user;
    NSString *_URL;
    NSString *_createdAt;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *createdAt;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

@end
