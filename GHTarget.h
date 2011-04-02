//
//  GHTarget.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHTarget : NSObject {
    NSNumber *_followers;
    NSString *_gravatarID;
    NSString *_login;
    NSNumber *_repos;
}

@property (nonatomic, copy) NSNumber *followers;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSNumber *repos;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
