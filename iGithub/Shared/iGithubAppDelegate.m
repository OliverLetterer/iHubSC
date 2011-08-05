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

@implementation iGithubAppDelegate

@synthesize window=_window;

@synthesize managedObjectContext=_managedObjectContext, managedObjectModel=_managedObjectModel, persistentStoreCoordinator=_persistentStoreCoordinator;

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
#ifdef DEBUG
    [self nowSerializeState];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
#ifndef DEBUG
    [self nowSerializeState];
#endif
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
    NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:self.lastKnownApplicationStateDictionaryFilePath];
    
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

#pragma mark - memory management

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GHDatabase" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GHDatabase.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
