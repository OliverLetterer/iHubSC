//
//  GHGist.m
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGist.h"
#import "GithubAPI.h"

@implementation GHGist

@synthesize URL=_URL, ID=_ID, description=_description, public=_public, user=_user, files=_files, comments=_comments, pullURL=_pullURL, pushURL=_pushURL, createdAt=_createdAt, forks=_forks;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.ID = [rawDictionay objectForKeyOrNilOnNullObject:@"id"];
        self.description = [rawDictionay objectForKeyOrNilOnNullObject:@"description"];
        self.user = [[[GHUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"]] autorelease];
        self.comments = [rawDictionay objectForKeyOrNilOnNullObject:@"comments"];
        self.pullURL = [rawDictionay objectForKeyOrNilOnNullObject:@"git_pull_url"];
        self.pushURL = [rawDictionay objectForKeyOrNilOnNullObject:@"git_push_url"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.public = [rawDictionay objectForKeyOrNilOnNullObject:@"public"];
        
        NSDictionary *filesDictionary = [rawDictionay objectForKeyOrNilOnNullObject:@"files"];
        NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:[filesDictionary count]];
        
        [filesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [filesArray addObject:[[[GHGistFile alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        
        self.files = filesArray;
        
        NSArray *rawArray = [rawDictionay objectForKeyOrNilOnNullObject:@"forks"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[[GHGistFork alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        
        self.forks = finalArray;
    }
    return self;
}

#pragma mark - downloading

+ (void)gistWithID:(NSString *)ID completionHandler:(void (^)(GHGist *, NSError *))handler {
    
    // v3: GET /gists/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHGist alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                           
                                       }];
    
}

+ (void)deleteGistWithID:(NSString *)ID completionHandler:(void (^)(NSError *))handler {
    // v3: DELETE /gists/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)isGistStarredWithID:(NSString *)ID completionHandler:(void(^)(BOOL starred, NSError *error))handler {
    // v3: GET /gists/:id/star
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/star", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           int responseCode = [request responseStatusCode];
                                           
                                           handler(responseCode == 204, nil);
                                       }];
}

+ (void)starGistWithID:(NSString *)ID completionHandler:(void (^)(NSError *))handler {
    // v3: POST /gists/:id/star
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/star", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"POST"];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)unstarGistWithID:(NSString *)ID completionHandler:(void (^)(NSError *))handler {
    // v3: DELETE /gists/:id/star
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/star", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)commentsForGistWithID:(NSString *)ID completionHandler:(void(^)(NSMutableArray *gists, NSError *error))handler {
    // v3: GET /gists/:gist_id/comments
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/comments", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   [finalArray addObject:[[[GHGistComment alloc] initWithRawDictionary:obj] autorelease] ];
                                               }];
                                               
                                               handler(finalArray, nil);
                                           }
                                           
                                       }];
}

+ (void)postComment:(NSString *)comment forGistWithID:(NSString *)ID completionHandler:(void (^)(GHGistComment *, NSError *))handler {
    // V3: POST /gists/:gist_id/comments
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/comments", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
                                                if (comment) {
                                                    [jsonDictionary setObject:comment forKey:@"body"];
                                                }
                                                
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                                
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHGistComment alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                       }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_ID release];
    [_description release];
    [_public release];
    [_user release];
    [_files release];
    [_comments release];
    [_pullURL release];
    [_pushURL release];
    [_createdAt release];
    [_forks release];
    
    [super dealloc];
}

@end
