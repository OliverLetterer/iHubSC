//
//  GHAPIGistForkV3.h
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIUserV3;

@interface GHAPIGistForkV3 : NSObject <NSCoding> {
@private
    GHAPIUserV3 *_user;
    NSString *_URL;
    NSString *_createdAt;
}

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *createdAt;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

@end
