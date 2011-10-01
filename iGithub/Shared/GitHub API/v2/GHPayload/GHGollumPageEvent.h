//
//  GHGollumPageEvent.h
//  iGithub
//
//  Created by Oliver Letterer on 01.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHGollumPageEvent : NSObject <NSCoding> {
@private
    NSString *_action;
    NSString *_pageName;
    NSString *_sha;
    NSString *_summary;
    NSString *_title;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *sha;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *title;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
