//
//  GHSettingsHelper.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSettingsHelper.h"
#import "SFHFKeychainUtils.h"

#define GHSettingsUsernameKey @"GHSettingsUsernameKey"
#define GHSettingsKeychainService @"de.olettere.iGithub"

@implementation GHSettingsHelper

+ (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GHSettingsUsernameKey];
}

+ (void)setUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:GHSettingsUsernameKey];
}

+ (NSString *)password {
    return [SFHFKeychainUtils getPasswordForUsername:[self username] 
                                      andServiceName:GHSettingsKeychainService 
                                               error:NULL];
}

+ (void)setPassword:(NSString *)password {
    [SFHFKeychainUtils storeUsername:[self username] 
                         andPassword:password 
                      forServiceName:GHSettingsKeychainService 
                      updateExisting:YES 
                               error:NULL];
}

+ (BOOL)isUserAuthenticated {
    return [self username] != nil && [self password] != nil;
}

@end
