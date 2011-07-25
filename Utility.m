//
//  Utility.m
//  iGithub
//
//  Created by Oliver Letterer on 25.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Utility.h"

id GHAPIObjectExpectedClass(id object, Class class) {
    return [object isKindOfClass:class] ? object : nil;
}
