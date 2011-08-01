//
//  GHAPIPullRequestMergeState.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIPullRequestMergeStateV3 : NSObject <NSCoding> {
@private
    NSString *_SHA;
    NSNumber *_merged;
    NSString *_message;
}

@property (nonatomic, copy) NSString *SHA;
@property (nonatomic, copy) NSNumber *merged;
@property (nonatomic, copy) NSString *message;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
