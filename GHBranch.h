//
//  GHBranch.h
//  iGithub
//
//  Created by Oliver Letterer on 17.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHBranch : NSObject {
@private
    NSString *_name;
    NSString *_hash;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *hash;

- (id)initWithName:(NSString *)name hash:(NSString *)hash;

@end
