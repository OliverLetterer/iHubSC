//
//  NSDictionary+GHNullTermination.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (GHNullTermination)

- (id)objectForKeyOrNilOnNullObject:(id)aKey;

@end
