//
//  iGithubAppDelegate.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface iGithubAppDelegate : NSObject <UIApplicationDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)setupAppearences;

@end
