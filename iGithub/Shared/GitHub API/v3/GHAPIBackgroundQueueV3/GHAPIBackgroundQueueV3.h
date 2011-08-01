//
//  GHAPIBackgroundQueueV3.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import "ASIFormDataRequest.h"
#import "GHAPIConnectionHandlersV3.h"

dispatch_queue_t GHAPIBackgroundQueue();

enum {
    GHAPIPaginationNextPageNotFound = 0
};

enum {
    GHAPIDefaultPaginationCount = 30
};

@interface GHAPIBackgroundQueueV3 : NSObject {
    dispatch_queue_t _backgroundQueue;
    dispatch_queue_t _imageQueue;
    NSUInteger _remainingAPICalls;
}

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property (nonatomic, readonly) dispatch_queue_t imageQueue;
@property (nonatomic, readonly) NSUInteger remainingAPICalls;

- (void)sendRequestToURL:(NSURL *)URL setupHandler:(void(^)(ASIFormDataRequest *request))setupHandler completionHandler:(void(^)(id object, NSError *error, ASIFormDataRequest *request))completionHandler;

- (void)sendRequestToURL:(NSURL *)URL page:(NSUInteger)page setupHandler:(void(^)(ASIFormDataRequest *request))setupHandler 
    completionPaginationHandler:(void(^)(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage))completionHandler;

@end


@interface GHAPIBackgroundQueueV3 (Singleton)

+ (GHAPIBackgroundQueueV3 *)sharedInstance;

@end
