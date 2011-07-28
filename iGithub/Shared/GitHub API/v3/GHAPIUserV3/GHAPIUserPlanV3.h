//
//  GHAPIUserPlanV3.h
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIUserPlanV3 : NSObject <NSCoding> {
@private
    NSString *_name;
    NSNumber *_space;
    NSNumber *_collaborators;
    NSNumber *_privateRepos;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *space;
@property (nonatomic, copy) NSNumber *collaborators;
@property (nonatomic, copy) NSNumber *privateRepos;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
