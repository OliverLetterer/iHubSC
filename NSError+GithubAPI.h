//
//  NSError+GithubAPI.h
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (GHGithubAPIAddition)

+ (NSError *)errorFromRawDictionary:(NSDictionary *)rawDictionary;

@end
