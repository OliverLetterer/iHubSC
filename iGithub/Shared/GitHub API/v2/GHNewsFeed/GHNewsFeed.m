//
//  GHNewsFeed.m
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeed.h"
#import "GithubAPI.h"
#import "ASIHTTPRequest.h"

@implementation GHNewsFeed

@synthesize items=_items;

#pragma mark - Initialization

+ (void)privateNewsWithCompletionHandler:(void(^)(GHNewsFeed *feed, NSError *error))handler {
    
    // use URL https://github.com/docmorelli.private.json
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@.private.json",
                                           [[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *feedData = [request responseData];
        NSString *feedString = [[NSString alloc] initWithData:feedData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                id object = [feedString objectFromJSONString];
                NSArray *feedArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                handler([[GHNewsFeed alloc] initWithRawArray:feedArray], nil);
            }
        });
    });
}

+ (void)newsFeedForUserNamed:(NSString *)username 
           completionHandler:(void(^)(GHNewsFeed *feed, NSError *error))handler {
    
    // use URL https://github.com/docmorelli.json
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@.json",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *feedData = [request responseData];
        NSString *feedString = [[NSString alloc] initWithData:feedData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                id object = [feedString objectFromJSONString];
                NSArray *feedArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                handler([[GHNewsFeed alloc] initWithRawArray:GHAPIObjectExpectedClass(&feedArray, NSArray.class)], nil);
            }
        });
    });
    
}

- (id)initWithRawArray:(NSArray *)rawArray {
    GHAPIObjectExpectedClass(&rawArray, NSArray.class);
    if ((self = [super init])) {
        // Initialization code
        NSMutableArray *items = [NSMutableArray array];
        for (NSDictionary *feedEntry in rawArray) {
            [items addObject:[[GHNewsFeedItem alloc] initWithRawDictionary:feedEntry] ];
        }
        self.items = items;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.items forKey:@"items"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    return self;
}

@end
