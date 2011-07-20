//
//  GHFileMetaData.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface GHFileMetaData : NSObject <NSCoding> {
@private
    NSString *_name;
    NSNumber *_size;
    NSString *_hash;
    NSString *_mode;
    NSString *_mimeType;
    
    NSString *_repository;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, copy) NSString *hash;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *repository;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

+ (void)metaDataOfFile:(NSString *)filename 
         atRelativeURL:(NSString *)URL 
          onRepository:(NSString *)repository 
                  tree:(NSString *)tree 
     completionHandler:(void(^)(GHFileMetaData *metaData, NSError *error))handler;

- (void)contentOfFileWithCompletionHandler:(void(^)(NSData *data, NSError *error))handler;

- (ASIHTTPRequest *)requestForContent;

@end
