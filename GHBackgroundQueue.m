//
//  GHBackgroundQueue.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHBackgroundQueue.h"

#import "GithubAPI.h"

dispatch_queue_t GHAPIBackgroundQueue() {
    return [GHBackgroundQueue sharedInstance].backgroundQueue;
}

@implementation GHBackgroundQueue

@synthesize remainingAPICalls=_remainingAPICalls;

- (dispatch_queue_t)backgroundQueue {
    if (!_backgroundQueue) {
        _backgroundQueue = dispatch_queue_create("de.olettere.GHAPI.backgroundQueue", NULL);
    }
    return _backgroundQueue;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _remainingAPICalls = 5000;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - instance methods

- (void)sendRequestToURL:(NSURL *)URL 
            setupHandler:(void(^)(ASIFormDataRequest *request))setupHandler 
       completionHandler:(void(^)(id object, NSError *error, ASIFormDataRequest *request))completionHandler {
    
    dispatch_async(self.backgroundQueue, ^(void) {
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        if (setupHandler) {
            setupHandler(request);
        }
        [request startSynchronous];
        
        NSString *XRatelimitRemaing = [[request responseHeaders] objectForKey:@"X-Ratelimit-Remaining"];
        _remainingAPICalls = [XRatelimitRemaing integerValue];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                completionHandler(nil, myError, request);
            } else {
                completionHandler([[request responseString] objectFromJSONString], nil, request);
            }
        });
        
    });
    
}

@end





#pragma mark - Singleton implementation

static GHBackgroundQueue *_instance = nil;

@implementation GHBackgroundQueue (Singleton)

+ (GHBackgroundQueue *)sharedInstance {
	@synchronized(self) {
		
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
	return [[self sharedInstance] retain];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {	
    return self;	
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
