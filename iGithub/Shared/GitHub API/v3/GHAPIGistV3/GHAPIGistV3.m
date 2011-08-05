//
//  GHAPIGistV3.m
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistV3.h"
#import "GithubAPI.h"

NSString *const GHAPIGistV3DeleteNotification = @"GHAPIGistV3DeleteNotification";
NSString *const GHAPIGistV3CreatedNotification = @"GHAPIGistV3CreatedNotification";


@implementation GHAPIGistV3

@synthesize URL=_URL, ID=_ID, description=_description, public=_public, user=_user, files=_files, comments=_comments, pullURL=_pullURL, pushURL=_pushURL, createdAt=_createdAt, forks=_forks;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.user = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"]];
        self.comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        self.pullURL = [rawDictionary objectForKeyOrNilOnNullObject:@"git_pull_url"];
        self.pushURL = [rawDictionary objectForKeyOrNilOnNullObject:@"git_push_url"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.public = [rawDictionary objectForKeyOrNilOnNullObject:@"public"];
        
        NSDictionary *filesDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"files"];
        NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:[filesDictionary count]];
        
        [filesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [filesArray addObject:[[GHAPIGistFileV3 alloc] initWithRawDictionary:obj] ];
        }];
        
        self.files = filesArray;
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"forks"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[GHAPIGistForkV3 alloc] initWithRawDictionary:obj] ];
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
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _description = [decoder decodeObjectForKey:@"description"];
        _public = [decoder decodeObjectForKey:@"public"];
        _user = [decoder decodeObjectForKey:@"user"];
        _files = [decoder decodeObjectForKey:@"files"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _pullURL = [decoder decodeObjectForKey:@"pullURL"];
        _pushURL = [decoder decodeObjectForKey:@"pushURL"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _forks = [decoder decodeObjectForKey:@"forks"];
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
                                               handler([[GHAPIGistV3 alloc] initWithRawDictionary:object], nil);
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
                                                [[NSNotificationCenter defaultCenter] postNotificationName:GHAPIGistV3DeleteNotification object:nil 
                                                                                                  userInfo:[NSDictionary dictionaryWithObject:ID forKey:GHAPIV3NotificationUserDictionaryGistIDKey]];
                                                handler(error);
                                            }];
}

+ (void)forkGistWithID:(NSString *)ID completionHandler:(void(^)(GHAPIGistV3 *gist, NSError *error))handler {
    // v3: POST /gists/:id/fork
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@/fork", 
                                       [ID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) {
                                                     [request setRequestMethod:@"POST"];
                                                 } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                     GHAPIGistV3 *gist = [[GHAPIGistV3 alloc] initWithRawDictionary:object];
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:GHAPIGistV3CreatedNotification object:nil 
                                                                                                       userInfo:[NSDictionary dictionaryWithObject:gist forKey:GHAPIV3NotificationUserDictionaryGistKey]];
                                                     handler(gist, nil);
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
                                               NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                               
                                               NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                               [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   [finalArray addObject:[[GHAPIGistCommentV3 alloc] initWithRawDictionary:obj] ];
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
                                                NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                                
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIGistCommentV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

@end
