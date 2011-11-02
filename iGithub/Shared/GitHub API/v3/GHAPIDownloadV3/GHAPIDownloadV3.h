//
//  GHAPIDownloadV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//



/**
 @class     GHAPIDownloadV3
 @abstract  <#abstract comment#>
 */
@interface GHAPIDownloadV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    NSString *_HTMLURL;
    NSNumber *_ID;
    NSString *_name;
    NSString *_description;
    NSNumber *_size;
    NSNumber *_downloadCount;
    NSString *_contentType;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@property (nonatomic, readonly) NSString *URL;
@property (nonatomic, readonly) NSString *HTMLURL;
@property (nonatomic, readonly) NSNumber *ID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) NSNumber *size;
@property (nonatomic, readonly) NSNumber *downloadCount;
@property (nonatomic, readonly) NSString *contentType;

@end
