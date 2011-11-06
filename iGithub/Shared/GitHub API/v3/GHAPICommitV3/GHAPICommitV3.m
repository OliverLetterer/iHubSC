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
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.author = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"author"] ];
        self.committer = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"committer"] ];
        self.message = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
        self.tree = [[GHAPITreeInfoV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"tree"] ];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"parents"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[GHAPITreeInfoV3 alloc] initWithRawDictionary:obj]];
        }];
        self.parents = finalArray;
        
        if (!self.message) {
            self.message = [[rawDictionary objectForKeyOrNilOnNullObject:@"commit"] objectForKeyOrNilOnNullObject:@"message"];
        }
        if (!self.tree.SHA) {
            self.tree = [[GHAPITreeInfoV3 alloc] initWithRawDictionary:[[rawDictionary objectForKeyOrNilOnNullObject:@"commit"] objectForKeyOrNilOnNullObject:@"tree"] ];
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPICommitV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_SHA forKey:@"sHA"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_author forKey:@"author"];
    [encoder encodeObject:_committer forKey:@"committer"];
    [encoder encodeObject:_message forKey:@"message"];
    [encoder encodeObject:_tree forKey:@"tree"];
    [encoder encodeObject:_parents forKey:@"parents"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _SHA = [decoder decodeObjectForKey:@"sHA"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _author = [decoder decodeObjectForKey:@"author"];
        _committer = [decoder decodeObjectForKey:@"committer"];
        _message = [decoder decodeObjectForKey:@"message"];
        _tree = [decoder decodeObjectForKey:@"tree"];
        _parents = [decoder decodeObjectForKey:@"parents"];
    }
    return self;
}

@end
