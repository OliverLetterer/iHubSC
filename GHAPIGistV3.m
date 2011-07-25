//
//  GHAPIGistV3.m
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistV3.h"
#import "GithubAPI.h"

@implementation GHAPIGistV3

@synthesize URL=_URL, ID=_ID, description=_description, public=_public, user=_user, files=_files, comments=_comments, pullURL=_pullURL, pushURL=_pushURL, createdAt=_createdAt, forks=_forks;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.user = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"]] autorelease];
        self.comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        self.pullURL = [rawDictionary objectForKeyOrNilOnNullObject:@"git_pull_url"];
        self.pushURL = [rawDictionary objectForKeyOrNilOnNullObject:@"git_push_url"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.public = [rawDictionary objectForKeyOrNilOnNullObject:@"public"];
        
        NSDictionary *filesDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"files"];
        NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:[filesDictionary count]];
        
        [filesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [filesArray addObject:[[[GHAPIGistFileV3 alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        
        self.files = filesArray;
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"forks"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[[GHAPIGistForkV3 alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        
        self.forks = finalArray;
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_description forKey:@"description"];
    [encoder encodeObject:_public forKey:@"public"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_files forKey:@"files"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_pullURL forKey:@"pullURL"];
    [encoder encodeObject:_pushURL forKey:@"pushURL"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_forks forKey:@"forks"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _description = [[decoder decodeObjectForKey:@"description"] retain];
        _public = [[decoder decodeObjectForKey:@"public"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _files = [[decoder decodeObjectForKey:@"files"] retain];
        _comments = [[decoder decodeObjectForKey:@"comments"] retain];
        _pullURL = [[decoder decodeObjectForKey:@"pullURL"] retain];
        _pushURL = [[decoder decodeObjectForKey:@"pushURL"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _forks = [[decoder decodeObjectForKey:@"forks"] retain];
    }
    return self;
}

#pragma mark - downloading

+ (void)gistWithID:(NSString *)ID completionHandler:(void (^)(GHAPIGistV3 *, NSError *))handler {
    
    // v3: GET /gists/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHAPIGistV3 alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                           
                                       }];
    
}

+ (void)deleteGistWithID:(NSString *)ID completionHandler:(void (^)(NSError *))handler {
    // v3: DELETE /gists/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)unstarGistWithID:(NSString *)ID completionHandler:(void (^)(NSError *))handler {
    // v3: DELETE /gists/:id/star
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/star", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
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
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSArray *rawArray = object;
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   [finalArray addObject:[[[GHAPIGistCommentV3 alloc] initWithRawDictionary:obj] autorelease] ];
                                               }];
                                               
                                               handler(finalArray, nil);
                                           }
                                           
                                       }];
}

+ (void)postComment:(NSString *)comment forGistWithID:(NSString *)ID completionHandler:(void (^)(GHAPIGistCommentV3 *, NSError *))handler {
    // V3: POST /gists/:gist_id/comments
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/comments", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
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
                                               handler([[[GHAPIGistCommentV3 alloc] initWithRawDictionary:object] autorelease], nil);
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
