//
//  GHAPITreeV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPITreeV3.h"
#import "GithubAPI.h"

@implementation GHAPITreeV3
@synthesize SHA=_SHA, URL=_URL, content=_content, directories=_directories, files=_files;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        DLog(@"%@", rawDictionary);
        // Initialization code
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"tree"];
        NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        NSMutableArray *directories = [NSMutableArray arrayWithCapacity:rawArray.count];
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GHAPITreeFileV3 *file = [[GHAPITreeFileV3 alloc] initWithRawDictionary:obj];
            
            [contentArray addObject:file];
            if (file.isDirectoy) {
                [directories addObject:file];
            } else {
                [files addObject:file];
            }
        }];
        self.content = contentArray;
        self.files = files;
        self.directories = directories;
    }
    return self;
}

#pragma mark - API calls

+ (void)contentOfBranch:(NSString *)branchHash onRepository:(NSString *)repository 
      completionHandler:(void(^)(GHAPITreeV3 *tree, NSError *error))handler {
    // v3: GET /repos/:user/:repo/git/trees/:sha
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/git/trees/%@", 
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [branchHash stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    handler([[GHAPITreeV3 alloc] initWithRawDictionary:object], nil);
                                                }
                                            }];
}

+ (void)treeOfCommit:(NSString *)commitID onRepository:(NSString *)repository completionHandler:(void(^)(GHAPITreeV3 *tree, NSError *error))handler {
    // v3: GET /repos/:user/:repo/git/commits/:sha
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/git/commits/%@", 
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [commitID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    NSDictionary *dictionary = object;
                                                    handler([[GHAPITreeV3 alloc] initWithRawDictionary:[dictionary objectForKeyOrNilOnNullObject:@"tree"] ], nil);
                                                }
                                            }];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.SHA forKey:@"sHA"];
    [encoder encodeObject:self.URL forKey:@"uRL"];
    [encoder encodeObject:self.content forKey:@"treeContent"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.SHA = [decoder decodeObjectForKey:@"sHA"];
        self.URL = [decoder decodeObjectForKey:@"uRL"];
        self.content = [decoder decodeObjectForKey:@"treeContent"];
    }
    return self;
}

@end
