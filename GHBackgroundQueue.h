//
//  GHBackgroundQueue.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

dispatch_queue_t GHAPIBackgroundQueue();

@interface GHBackgroundQueue : NSObject {
    dispatch_queue_t _backgroundQueue;
}

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;

@end


@interface GHBackgroundQueue (Singleton)

+ (GHBackgroundQueue *)sharedInstance;

@end
