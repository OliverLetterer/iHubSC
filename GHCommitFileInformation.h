//
//  GHCommitFileInformation.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHCommitFileInformation : NSObject {
@private
    NSString *_diff;
    NSString *_filename;
}

@property (nonatomic, copy) NSString *diff;
@property (nonatomic, copy) NSString *filename;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
