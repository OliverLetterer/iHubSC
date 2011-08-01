//
//  GHFile.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHFileSystemItem.h"

@interface GHFile : GHFileSystemItem {
@private
    NSString *_hash;
}

@property (nonatomic, copy) NSString *hash;

- (id)initWithName:(NSString *)name hash:(NSString *)hash;

- (NSComparisonResult)caseInsensitiveCompare:(GHFile *)aFile;

@end
