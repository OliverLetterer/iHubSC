//
//  GHFileSystemItem.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GHFileSystemItemTypeDirectory = 0,
    GHFileSystemItemTypeFile
} GHFileSystemItemType;

@interface GHFileSystemItem : NSObject <NSCoding> {
@protected
    NSString *_name;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, readonly) GHFileSystemItemType type;

@end
