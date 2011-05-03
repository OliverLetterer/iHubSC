//
//  GHGist.h
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUser;

@interface GHGist : NSObject {
@private
    NSString *_URL;
    NSString *_ID;
    NSString *_description;
    NSNumber *_public;
    GHUser *_user;
    NSArray *_files;
    NSNumber *_comments;
    NSString *_pullURL;
    NSString *_pushURL;
    NSString *_createdAt;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *public;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *pullURL;
@property (nonatomic, copy) NSString *pushURL;
@property (nonatomic, copy) NSString *createdAt;

#warning check if "id" is really a string

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

@end
