//
//  GHDownloadEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

@interface GHDownloadEventPayload : GHPayload {
    NSNumber *_ID;
    NSString *_URL;
}

@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *URL;

@end
