//
//  GHAPIRepositoryBranchV3.h
//  iGithub
//
//  Created by Oliver Letterer on 11.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIRepositoryBranchV3 : NSObject <NSCoding> {
@private
    NSString *_name;
    NSString *_ID;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ID;

- (id)initWithName:(NSString *)name ID:(NSString *)ID;
- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
