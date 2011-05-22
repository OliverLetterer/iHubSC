//
//  GHAPIRepositoryV3.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIRepositoryV3.h"
#import "GithubAPI.h"

@implementation GHAPIRepositoryV3

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        // Initialization code
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - downloading

+ (void)labelOnRepository:(NSString *)repository completionHandler:(void(^)(NSArray *labels, NSError *error))handler {
    // v3: GET /repos/:user/:repo/labels
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/labels",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               for (NSDictionary *rawDictionary in rawArray) {
                                                   [finalArray addObject:[[[GHAPILabelV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                               }
                                               
                                               handler(finalArray, nil);
                                           }
                                       }];
}

@end
