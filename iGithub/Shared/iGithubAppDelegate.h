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
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, readonly) NSMutableDictionary *serializedStateDictionary;
@property (nonatomic, readonly) NSString *lastKnownApplicationStateDictionaryFilePath;

- (void)setupAppearences;

- (void)nowSerializeState;
- (BOOL)serializeStateInDictionary:(NSMutableDictionary *)dictionary;
- (NSMutableDictionary *)deserializeState;

@end
