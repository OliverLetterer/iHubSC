//
//  GHAPIGollumPageV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#warning NSCoding



/**
 @class     GHAPIGollumPageV3
 @abstract  one page of GHAPIGollumEventV3.
 */
@interface GHAPIGollumPageV3 : NSObject {
@private
    NSString *_pageName;
    NSString *_title;
    NSString *_action;
    NSString *_SHA;
    NSString *_HTMLURL;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@property (nonatomic, readonly) NSString *pageName;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSString *SHA;
@property (nonatomic, readonly) NSString *HTMLURL;

@end
