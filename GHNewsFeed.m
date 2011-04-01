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

+ (void)privateNewsFeedForUserNamed:(NSString *)username 
                           password:(NSString *)password 
                  completionHandler:(void(^)(GHNewsFeed *feed, NSError *error))handler {
    
    // use URL https://github.com/docmorelli.private.json
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@.private.json",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL];
        [request addRequestHeader:@"Authorization" 
                            value:[NSString stringWithFormat:@"Basic %@",[ASIHTTPRequest base64forData:[[NSString stringWithFormat:@"%@:%@",username,password] dataUsingEncoding:NSUTF8StringEncoding]]]];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *feedData = [request responseData];
        NSString *feedString = [[[NSString alloc] initWithData:feedData encoding:NSUTF8StringEncoding] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSArray *feedArray = [feedString objectFromJSONString];
                handler([[[GHNewsFeed alloc] initWithRawArray:feedArray] autorelease], nil);
            }
        });
    });
}

- (id)initWithRawArray:(NSArray *)rawArray {
    if ((self = [super init])) {
        // Initialization code
        NSMutableArray *items = [NSMutableArray array];
        for (NSDictionary *feedEntry in rawArray) {
            [items addObject:[[[GHNewsFeedItem alloc] initWithRawDictionary:feedEntry] autorelease] ];
        }
        self.items = items;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_items release];
    [super dealloc];
}

@end
