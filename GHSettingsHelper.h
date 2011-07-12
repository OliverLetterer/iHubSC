//
//  GHSettingsHelper.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHSettingsHelper : NSObject {
    
}

+ (NSString *)username;
+ (void)setUsername:(NSString *)username;

+ (NSString *)password;
+ (void)setPassword:(NSString *)password;

+ (NSString *)avatarURL;
+ (void)setAvatarURL:(NSString *)avatarURL;

+ (BOOL)isUserAuthenticated;

@end
