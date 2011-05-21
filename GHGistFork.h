//
//  GHGistFork.h
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUserV3;

@interface GHGistFork : NSObject {
@private
    GHUserV3 *_user;
    NSString *_URL;
    NSString *_createdAt;
}

@property (nonatomic, retain) GHUserV3 *user;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *createdAt;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

@end
