//
//  GHAPITreeInfoV3.h
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPITreeInfoV3 : NSObject {
@private
    NSString *_URL;
    NSString *_SHA;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *SHA;

@end
