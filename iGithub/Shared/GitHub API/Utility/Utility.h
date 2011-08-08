//
//  Utility.h
//  iGithub
//
//  Created by Oliver Letterer on 25.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline id GHAPIObjectExpectedClass(id *object, Class class) {
    if (![*object isKindOfClass:class]) {
        *object = nil;
    }
    return *object;
}
