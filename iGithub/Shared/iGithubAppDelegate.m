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
#import "BlocksKit.h"

@implementation iGithubAppDelegate
@synthesize window=_window;

#pragma mark - setters and getters

- (NSString *)lastDetectedURLString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDetectedURLString"];
}

- (void)setLastDetectedURLString:(NSString *)lastDetectedURLString
{
    [[NSUserDefaults standardUserDefaults] setObject:lastDetectedURLString forKey:@"lastDetectedURLString"];
}

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
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    static NSString *githubPrefix = @"https://github.com/";
    
    NSString *githubURLString = pasteboard.string;
    
    if ([githubURLString hasPrefix:githubPrefix] && ![githubURLString isEqualToString:self.lastDetectedURLString] && [GHAPIAuthenticationManager sharedInstance].authenticatedUser != nil) {
        NSURL *githubURL = [NSURL URLWithString:githubURLString];
        
        NSMutableArray *pathComponents = githubURL.pathComponents.mutableCopy;
        [pathComponents removeObject:@"/"];
        
        NSString *username = nil;
        NSString *repository = nil;
        
        if (pathComponents.count > 0) {
            // first index can contain a user name
            username = [pathComponents objectAtIndex:0];
        }
        
        if (pathComponents.count > 1) {
            NSString *repositoryName = [pathComponents objectAtIndex:1];
            if (![repository.lowercaseString isEqualToString:@"following"] && ![repositoryName.lowercaseString isEqualToString:@"repositories"]) {
                repository = [NSString stringWithFormat:@"%@/%@", [pathComponents objectAtIndex:0], repositoryName];
            }
        }
        
        if (username != nil || repository != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GitHub URL detected", @"") 
                                                            message:nil
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                  otherButtonTitles:nil];
            if (username) {
                [alert addButtonWithTitle:username
                                  handler:^{
                                      [self showUserWithName:username];
                                  }];
            }
            if (repository) {
                [alert addButtonWithTitle:repository
                                  handler:^{
                                      [self showRepositoryWithName:repository];
                                  }];
            }
            
            [alert show];
        }
        
        self.lastDetectedURLString = githubURLString;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)showUserWithName:(NSString *)username
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)showRepositoryWithName:(NSString *)repositoryString
{
    [self doesNotRecognizeSelector:_cmd];
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
