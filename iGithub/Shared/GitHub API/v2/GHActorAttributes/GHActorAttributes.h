//
//  GHActorAttributes.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHActorAttributes : NSObject <NSCoding> {
    NSString *_blog;
    NSString *_company;
    NSString *_EMail;
    NSString *_gravatarID;
    NSString *_location;
    NSString *_login;
    NSString *_name;
    NSString *_type;
}

@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
