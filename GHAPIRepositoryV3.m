//
//  GHAPIRepositoryV3.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIRepositoryV3.h"
#import "GithubAPI.h"

@interface GHAPIRepositoryV3 ()

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary parseChildren:(BOOL)parse;

@end

@implementation GHAPIRepositoryV3

@synthesize URL = _URL, HTMLURL = _HTMLURL, owner = _owner, name = _name, description = _description, homepage = _homepage, language = _language, private = _private, fork = _fork, forks = _forks, watchers = _watchers, size = _size, openIssues = _openIssues, pushedAt = _pushedAt, createdAt = _createdAt, organization = _organization, parent = _parent, source = _source, masterBranch = _masterBranch, hasIssues = _hasIssues, hasWiki = _hasWiki, hasDownloads = _hasDownloads;

#pragma mark - setters and getters

- (BOOL)hasLanguage {
    return self.language != nil;
}

- (BOOL)hasHomepage {
    return self.homepage != nil && ![self.homepage isEqualToString:@""];
}

- (BOOL)isForked {
    return [self.fork boolValue];
}

- (NSString *)description {
    if (!_description) {
        return [super description];
    }
    return _description;
}

- (NSString *)fullRepositoryName {
    return [NSString stringWithFormat:@"%@/%@", self.owner.login, self.name];
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary parseChildren:(BOOL)parse {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.HTMLURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        self.owner = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"owner"]];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.homepage = [rawDictionary objectForKeyOrNilOnNullObject:@"homepage"];
        self.language = [rawDictionary objectForKeyOrNilOnNullObject:@"language"];
        self.private = [rawDictionary objectForKeyOrNilOnNullObject:@"private"];
        self.fork = [rawDictionary objectForKeyOrNilOnNullObject:@"fork"];
        self.forks = [rawDictionary objectForKeyOrNilOnNullObject:@"forks"];
        self.watchers = [rawDictionary objectForKeyOrNilOnNullObject:@"watchers"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        self.openIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"open_issues"];
        self.pushedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"pushed_at"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.organization = [[GHAPIOrganizationV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"organization"]];
        if (parse) {
            self.parent = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"parent"] parseChildren:NO];
            self.source = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"source"] parseChildren:NO];
        }
        self.masterBranch = [rawDictionary objectForKeyOrNilOnNullObject:@"master_branch"];
        self.hasIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"has_issues"];
        self.hasWiki = [rawDictionary objectForKeyOrNilOnNullObject:@"has_wiki"];
        self.hasDownloads = [rawDictionary objectForKeyOrNilOnNullObject:@"has_downloads"];
    }
    return self;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [self initWithRawDictionary:rawDictionary parseChildren:YES])) {
        
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_HTMLURL forKey:@"hTMLURL"];
    [encoder encodeObject:_owner forKey:@"owner"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_description forKey:@"description"];
    [encoder encodeObject:_homepage forKey:@"homepage"];
    [encoder encodeObject:_language forKey:@"language"];
    [encoder encodeObject:_private forKey:@"private"];
    [encoder encodeObject:_fork forKey:@"fork"];
    [encoder encodeObject:_forks forKey:@"forks"];
    [encoder encodeObject:_watchers forKey:@"watchers"];
    [encoder encodeObject:_size forKey:@"size"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_pushedAt forKey:@"pushedAt"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_organization forKey:@"organization"];
    [encoder encodeObject:_parent forKey:@"parent"];
    [encoder encodeObject:_source forKey:@"source"];
    [encoder encodeObject:_masterBranch forKey:@"masterBranch"];
    [encoder encodeObject:_hasIssues forKey:@"hasIssues"];
    [encoder encodeObject:_hasWiki forKey:@"hasWiki"];
    [encoder encodeObject:_hasDownloads forKey:@"hasDownloads"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _HTMLURL = [decoder decodeObjectForKey:@"hTMLURL"];
        _owner = [decoder decodeObjectForKey:@"owner"];
        _name = [decoder decodeObjectForKey:@"name"];
        _description = [decoder decodeObjectForKey:@"description"];
        _homepage = [decoder decodeObjectForKey:@"homepage"];
        _language = [decoder decodeObjectForKey:@"language"];
        _private = [decoder decodeObjectForKey:@"private"];
        _fork = [decoder decodeObjectForKey:@"fork"];
        _forks = [decoder decodeObjectForKey:@"forks"];
        _watchers = [decoder decodeObjectForKey:@"watchers"];
        _size = [decoder decodeObjectForKey:@"size"];
        _openIssues = [decoder decodeObjectForKey:@"openIssues"];
        _pushedAt = [decoder decodeObjectForKey:@"pushedAt"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _organization = [decoder decodeObjectForKey:@"organization"];
        _parent = [decoder decodeObjectForKey:@"parent"];
        _source = [decoder decodeObjectForKey:@"source"];
        _masterBranch = [decoder decodeObjectForKey:@"masterBranch"];
        _hasIssues = [decoder decodeObjectForKey:@"hasIssues"];
        _hasWiki = [decoder decodeObjectForKey:@"hasWiki"];
        _hasDownloads = [decoder decodeObjectForKey:@"hasDownloads"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - API calls

+ (void)labelsOnRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /repos/:user/:repo/labels
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/labels",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                    page:page 
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPILabelV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)repositoryNamed:(NSString *)repositoryName 
  withCompletionHandler:(void (^)(GHAPIRepositoryV3 *repository, NSError *error))handler {
    // v3: GET /repos/:user/:repo
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@",
                                       [repositoryName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIRepositoryV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)repositoriesForUserNamed:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    NSURL *URL = nil;
    
    if ([username isEqualToString:[GHAPIAuthenticationManager sharedInstance].username]) {
        // authenticated user
        // v3: GET /user/repos
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/repos"] ];
    } else {
        // v3: GET /users/:user/repos
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/repos",
                                    [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    }
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                    page:page 
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[GHAPIRepositoryV3 alloc] initWithRawDictionary:rawDictionary] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)branchesOnRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /repos/:user/:repo/branches
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/branches",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIRepositoryBranchV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)repositoriesThatUserIsWatching:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /users/:user/watched
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/watched",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIRepositoryV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)watchersOfRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /repos/:user/:repo/watchers
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/watchers",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIUserV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)isWatchingRepository:(NSString *)repository completionHandler:(void (^)(BOOL watching, NSError *error))handler {
    // v3: GET /user/watched/:user/:repo
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/watched/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if ([request responseStatusCode] == 404) {
                                               handler(NO, nil);
                                           } else if (error) {
                                               handler(NO, error);
                                           } else {
                                               handler([request responseStatusCode] == 204, nil);
                                           }
                                       }];
}

+ (void)watchRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler {
    // v3: PUT /user/watched/:user/:repo
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/watched/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)unwatchRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler {
    // v3: PUT /user/watched/:user/:repo
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/watched/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)collaboratorsForRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /repos/:user/:repo/collaborators
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/collaborators",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPIUserV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)isUser:(NSString *)username collaboratorOnRepository:(NSString *)repository completionHandler:(GHAPIStateHandler)handler {
    // v3: GET /repos/:user/:repo/collaborators/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/collaborators/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                                       ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:nil 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if ([request responseStatusCode] == 404) {
                                               handler(NO, nil);
                                           } else if (error) {
                                               handler(NO, error);
                                           } else {
                                               handler([request responseStatusCode] == 204, nil);
                                           }
                                       }];
}

+ (void)createRepositoryWithName:(NSString *)name description:(NSString *)description 
                          public:(BOOL)public completionHandler:(void (^)(GHAPIRepositoryV3 *repository, NSError *error))handler {
    // v3: POST /user/repos
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/user/repos"]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"POST"];
                                                
                                                NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
                                                
                                                if (name) {
                                                    [jsonDictionary setObject:name forKey:@"name"];
                                                }
                                                if (description) {
                                                    [jsonDictionary setObject:description forKey:@"description"];
                                                }
                                                [jsonDictionary setObject:[NSNumber numberWithBool:public] forKey:@"public"];
                                                
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                                
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    handler([[GHAPIRepositoryV3 alloc] initWithRawDictionary:object], nil);
                                                }
                                            }];
}

+ (void)forkRepository:(NSString *)repository 
        toOrganization:(NSString *)organization completionHandler:(void (^)(GHAPIRepositoryV3 *repository, NSError *error))handler {
    // POST /repos/:user/:repo/forks?org=organization
    
    NSString *URLString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/forks", 
                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if (organization) {
        URLString = [URLString stringByAppendingFormat:@"?org=%@", [organization stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"POST"];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIRepositoryV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)deleteCollaboratorNamed:(NSString *)collaborator onRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler {
    // v3: DELETE /repos/:user/:repo/collaborators/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/collaborators/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [collaborator stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"DELETE"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)addCollaboratorNamed:(NSString *)collaborator onRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler {
    // v3: PUT /repos/:user/:repo/collaborators/:user
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/collaborators/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       [collaborator stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                            } completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
                                            }];
}

+ (void)commitsOnRepository:(NSString *)repository 
                  branchSHA:(NSString *)branchSHA 
                       page:(NSUInteger)page 
          completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /repos/:user/:repo/commits
    
    NSMutableString *URLString = [NSMutableString stringWithFormat:@"https://api.github.com/repos/%@/commits",
                                  [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if (branchSHA) {
        [URLString appendFormat:@"?sha=%@", [branchSHA stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                    page:page 
                                            setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = GHAPIObjectExpectedClass(object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [finalArray addObject:[[GHAPICommitV3 alloc] initWithRawDictionary:obj] ];
                                     }];
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

@end
