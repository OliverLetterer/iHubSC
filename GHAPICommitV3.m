//
//  GHAPICommitV3.m
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPICommitV3.h"
#import "GithubAPI.h"

@implementation GHAPICommitV3

@synthesize SHA = _SHA, URL = _URL, author = _author, committer = _committer, message = _message, tree = _tree, parents = _parents;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.author = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"author"] ] autorelease];
        self.committer = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"committer"] ] autorelease];
        self.message = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
        self.tree = [[[GHAPITreeInfoV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"tree"] ] autorelease];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"parents"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[[GHAPITreeInfoV3 alloc] initWithRawDictionary:obj] autorelease]];
        }];
        self.parents = finalArray;
        
        if (!self.message) {
            self.message = [[rawDictionary objectForKeyOrNilOnNullObject:@"commit"] objectForKeyOrNilOnNullObject:@"message"];
        }
        if (!self.tree.SHA) {
            self.tree = [[[GHAPITreeInfoV3 alloc] initWithRawDictionary:[[rawDictionary objectForKeyOrNilOnNullObject:@"commit"] objectForKeyOrNilOnNullObject:@"tree"] ] autorelease];
        }
    }
    return self;
}

#pragma mark - Network

+ (void)singleCommitOnRepository:(NSString *)repository branchSHA:(NSString *)branchSHA completionHandler:(void (^)(GHAPICommitV3 *commit, NSError *error))handler {
    //v3: GET /repos/:user/:repo/commits/:sha
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/commits/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [branchSHA stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           DLog(@"%@", [request responseString]);
                                           if (error) {
                                               DLog(@"%@", [error localizedDescription]);
                                               handler(nil, error);
                                           } else {
                                               DLog(@"%@", object);
                                               handler([[[GHAPICommitV3 alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                       }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_SHA release];
    [_URL release];
    [_author release];
    [_committer release];
    [_message release];
    [_tree release];
    [_parents release];
    
    [super dealloc];
}

@end
