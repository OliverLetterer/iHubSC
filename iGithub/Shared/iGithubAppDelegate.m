//
//  iGithubAppDelegate.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate.h"
#import "GHAPIAuthenticationManager.h"
#import "ASIHTTPRequest.h"
#import "ANNotificationQueue.h"
#import "GithubAPI.h"

@implementation iGithubAppDelegate
@synthesize window=_window;

- (NSMutableDictionary *)serializedStateDictionary {
    return nil;
}

- (NSString *)lastKnownApplicationStateDictionaryFilePath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"de.olettere.iGitHub.lastKnownApplicationState.plist"];
    
    return filePath;
}

- (void)setupAppearences {
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ASIHTTPRequest setDefaultTimeOutSeconds:20.0];
    [ANNotificationQueue sharedInstance];
    
    [self setupAppearences];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self nowSerializeState];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Serializations

- (void)nowSerializeState {
    [self serializeStateInDictionary:self.serializedStateDictionary];
}

- (BOOL)serializeStateInDictionary:(NSMutableDictionary *)dictionary {
    if (!dictionary) {
        return NO;
    }
    
    // save bundleVerion
    NSString *bundleVersionKey = (NSString *)kCFBundleVersionKey;
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:bundleVersionKey];
    if (bundleVersion) {
        [dictionary setObject:bundleVersion forKey:bundleVersionKey];
    }
    
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:UI_USER_INTERFACE_IDIOM()] forKey:@"UI_USER_INTERFACE_IDIOM"];
    
    return [NSKeyedArchiver archiveRootObject:dictionary toFile:self.lastKnownApplicationStateDictionaryFilePath];
}

- (NSMutableDictionary *)deserializeState {
    NSMutableDictionary *dictionary = nil;
    @try {
        dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:self.lastKnownApplicationStateDictionaryFilePath];
    }
    @catch (NSException *exception) {
        DLog(@"WARNING: Caught exception while deserializeState: %@", exception);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:self.lastKnownApplicationStateDictionaryFilePath error:NULL];
    
    NSString *bundleVersionKey = (NSString *)kCFBundleVersionKey;
    NSString *newBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:bundleVersionKey];
    NSString *oldBundleVersion = [dictionary objectForKey:bundleVersionKey];
    if (![newBundleVersion isEqual:oldBundleVersion]) {
        return nil;
    }
    NSNumber *idiom = [dictionary objectForKey:@"UI_USER_INTERFACE_IDIOM"];
    if ([idiom unsignedIntegerValue] != UI_USER_INTERFACE_IDIOM()) {
        return nil;
    }
    
    return dictionary;
}

@end
