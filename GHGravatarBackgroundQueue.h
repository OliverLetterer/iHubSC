//
//  GHGravatarBackgroundQueue.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface GHGravatarBackgroundQueue : NSObject {
    dispatch_queue_t _backgroundQueue;
    
    NSCache *_imagesCache;
}

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property (nonatomic, retain)  NSCache *imagesCache;

@end


@interface GHGravatarBackgroundQueue (Singleton)

+ (GHGravatarBackgroundQueue *)sharedInstance;

@end
