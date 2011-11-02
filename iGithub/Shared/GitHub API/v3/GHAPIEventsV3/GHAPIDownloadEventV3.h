//
//  GHAPIDownloadEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIDownloadV3.h"



/**
 @class     GHAPIDownloadEventEventV3
 @abstract  The download that was just created.
 */
@interface GHAPIDownloadEventV3 : GHAPIEventV3 <NSCoding> {
@private
    GHAPIDownloadV3 *_download;
}

@property (nonatomic, readonly) GHAPIDownloadV3 *download;

@end
