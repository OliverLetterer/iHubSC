//
//  GHDirectory.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHFileSystemItem.h"

@interface GHDirectory : GHFileSystemItem {
@private
    NSArray *_directories;
    NSArray *_files;
}

@property (nonatomic, retain) NSArray *directories;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, readonly) NSString *lastNameComponent;

/*
 dictionary must contain the files in the following structure:
 
 {
    ".gitignore" = bee4a00ac15a6ce318a5f4cd1b9b2a72226a58b8;
    ".gitmodules" = 8e55411afdcc971951e60eb3a31f26c41a73f95b;
    "Entitlements.plist" = 9c4c65dcada66660f6712a2b4d898b4ef1ca2774;
    "Frameworks/libcrypto.a" = e945d7488f4bf7fa607de1a51e0979778dc9f586;
    "Frameworks/libssl.a" = 6d5c08bc19e1b8a5773f77dd5acfcc285f352365;
    "Installous.xcodeproj/project.pbxproj" = f03d5fdfc414d831e436c7e58a1f0833c7a8b0e4;
    "Installous.xcodeproj/project.xcworkspace/contents.xcworkspacedata" = 43a6094b5477bd173a9660254d7dd8c20f031f3f;
 }
 */
- (id)initWithFilesDictionary:(NSDictionary *)dictionary name:(NSString *)name;

- (NSComparisonResult)caseInsensitiveCompare:(GHDirectory *)aDirectory;

@end
