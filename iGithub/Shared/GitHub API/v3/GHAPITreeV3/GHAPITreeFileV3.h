//
//  GHAPITreeFileV3.h
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kGHAPITreeFileV3TypeBlob;
extern NSString *const kGHAPITreeFileV3TypeTree;

@interface GHAPITreeFileV3 : NSObject <NSCoding> {
@private
    NSString *_path;
    NSString *_mode;
    NSString *_type;
    NSNumber *_size;
    NSString *_SHA;
    NSString *_URL;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, copy) NSString *SHA;
@property (nonatomic, copy) NSString *URL;

@property (nonatomic, readonly) BOOL isDirectoy;


- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
