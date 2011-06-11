//
//  GHAPIConnectionHandlers.h
//  iGithub
//
//  Created by Oliver Letterer on 11.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GHAPIPaginationHandler)(NSMutableArray *array, NSUInteger nextPage, NSError *error);
typedef void(^GHAPIErrorHandler)(NSError *error);
typedef void(^GHAPIStateHandler)(BOOL state, NSError *error);
