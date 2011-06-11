//
//  GHRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRepository.h"
#import "GithubAPI.h"
#import "ASIHTTPRequest.h"

@implementation GHRepository

@synthesize creationDate=_creationDate, desctiptionRepo=_desctiptionRepo, fork=_fork, forks=_forks, hasDownloads=_hasDownloads, hasIssues=_hasIssues, hasWiki=_hasWiki, homePage=_homePage, integrateBranch=_integrateBranch, language=_language, name=_name, openIssues=_openIssues, owner=_owner, parent=_parent, private=_private, pushedAt=_pushedAt, size=_size, source=_source, URL=_URL, watchers=_watchers;

- (BOOL)isHomepageAvailable {
    return ![self.homePage isEqualToString:@""] && self.homePage;
}

- (BOOL)hasLanguage {
    return self.language != nil;
}

- (BOOL)hasHomepage {
    return ![self.homePage isEqualToString:@""] && self.homePage;
}

- (BOOL)isForked {
    return self.source != nil;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@/%@", self.owner, self.name];
}

#pragma mark - class methods

+ (void)collaboratorsForRepository:(NSString *)repository 
                 completionHandler:(void (^)(NSArray *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@/collaborators",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                           ]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *jsonData = [request responseData];
        NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *info = [jsonString objectFromJSONString];
                NSArray *collaborators = [info objectForKey:@"collaborators"];
                handler(collaborators, nil);
            }
        });
    });
    
}

//+ (void)repositoriesForUserNamed:(NSString *)username 
//               completionHandler:(void (^)(NSArray *array, NSError *error))handler {
//    
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@",
//                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
//                                           ]];
//        NSError *myError = nil;
//        
//        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        NSString *jsonString = [request responseString];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if (myError) {
//                handler(nil, myError);
//            } else {
//                NSDictionary *reposDictionary = [jsonString objectFromJSONString];
//                NSArray *repos = [reposDictionary objectForKey:@"repositories"];
//                
//                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[repos count] ];
//                for (NSDictionary *rawRepository in repos) {
//                    [array addObject:[[[GHRepository alloc] initWithRawDictionary:rawRepository] autorelease] ];
//                }
//                
//                handler(array, nil);
//            }
//        });
//    });
//    
//}

+ (void)createRepositoryWithTitle:(NSString *)title 
                      description:(NSString *)description public:(BOOL)public completionHandler:(void (^)(GHRepository *repository, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/create"]];
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        
        [request setPostValue:title forKey:@"name"];
        [request setPostValue:description forKey:@"description"];
        [request setPostValue:[NSString stringWithFormat:@"%d", public] forKey:@"public"];
        
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dict = [[request responseString] objectFromJSONString];
                handler([[[GHRepository alloc] initWithRawDictionary:dict] autorelease], nil);
            }
        });
    });
}

//+ (void)watchedRepositoriesOfUser:(NSString *)username 
//                completionHandler:(void (^)(NSArray *array, NSError *error))handler {
//    
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // /repos/watched/:user
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/watched/%@", [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        if (!myError) {
//            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
//        }
//        
//        NSString *jsonString = [request responseString];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if (myError) {
//                handler(nil, myError);
//            } else {
//                NSDictionary *dictionary = [jsonString objectFromJSONString];
//                NSArray *allReposArray = [dictionary objectForKey:@"repositories"];
//                
//                NSMutableArray *repos = [NSMutableArray arrayWithCapacity:[allReposArray count]];
//                
//                for (NSDictionary *rawDictionary in allReposArray) {
//                    [repos addObject:[[[GHRepository alloc] initWithRawDictionary:rawDictionary] autorelease] ];
//                }
//                
//                handler(repos, nil);
//            }
//        });
//    });
//}

//+ (void)repository:(NSString *)repository withCompletionHandler:(void (^)(GHRepository *repository, NSError *error))handler {
//    
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // repos/show/:user/:repo
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@", [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        if (!myError) {
//            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
//        }
//        
//        NSString *jsonString = [request responseString];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if (myError) {
//                handler(nil, myError);
//            } else {
//                NSDictionary *rawDictionary = [jsonString objectFromJSONString];
//                handler([[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKey:@"repository"] ] autorelease], nil);
//            }
//        });
//    });
//}

//+ (void)watchingUserOfRepository:(NSString *)repository 
//           withCompletionHandler:(void (^)(NSArray *watchingUsers, NSError *error))handler {
//    
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // http://github.com/api/v2/json/repos/show/claudiob/csswaxer/watchers?full=1
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@/watchers", [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        if (!myError) {
//            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
//        }
//        
//        NSString *jsonString = [request responseString];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if (myError) {
//                handler(nil, myError);
//            } else {
//                NSDictionary *dictionary = [jsonString objectFromJSONString];
//                
//                handler([dictionary objectForKey:@"watchers"], nil);
//                
//            }
//        });
//    });
//}

+ (void)deleteTokenForRepository:(NSString *)repository 
           withCompletionHandler:(void (^)(NSString *deleteToken, NSError *error))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // repos/delete/:user/:repo
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/delete/%@/", [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        NSString *jsonString = [request responseString];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dict = [jsonString objectFromJSONString];
                handler([dict objectForKey:@"delete_token"], nil);
            }
        });
    });
}

+ (void)deleteRepository:(NSString *)repository 
               withToken:(NSString *)token 
       completionHandler:(void (^)(NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // repos/delete/:user/:repo
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/delete/%@/", [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setPostValue:token forKey:@"delete_token"];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(myError);
            } else {
                handler(nil);
            }
        });
    });
}

//+ (void)followRepositorie:(NSString *)repository completionHandler:(void (^)(NSError *error))handler {
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // repos/watch/:user/:repo
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/watch/%@",
//                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
//        
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            handler(myError);
//        });
//    });
//}

//+ (void)unfollowRepositorie:(NSString *)repository completionHandler:(void (^)(NSError *error))handler {
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // repos/unwatch/:user/:repo
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/unwatch/%@",
//                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
//        
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            handler(myError);
//        });
//    });
//}

//+ (void)branchesOnRepository:(NSString *)repository completionHandler:(void (^)(NSArray *, NSError *))handler {
//    
//    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
//        
//        // repos/show/:user/:repo/branches
//        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@/branches",
//                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
//        
//        NSError *myError = nil;
//        
//        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
//        [request startSynchronous];
//        
//        myError = [request error];
//        
//        if (!myError) {
//            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if (myError) {
//                handler(nil, myError);
//            } else {
//                NSDictionary *dictionary = [[[request responseString] objectFromJSONString] objectForKeyOrNilOnNullObject:@"branches"];
//                
//                NSMutableArray *branches = [NSMutableArray array];
//                for (NSString *branch in [dictionary allKeys]) {
//                    NSString *hash = [dictionary objectForKey:branch];
//                    [branches addObject:[[[GHBranch alloc] initWithName:branch hash:hash] autorelease] ];
//                }
//                handler(branches, nil);
//            }
//        });
//    });
//}

+ (void)recentCommitsOnRepository:(NSString *)repository 
                           branch:(NSString *)branch 
                completionHandler:(void (^)(NSArray *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // commits/list/:user_id/:repository/:branch
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/commits/list/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           [branch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [[request responseString] objectFromJSONString];
                NSArray *array = [dictionary objectForKeyOrNilOnNullObject:@"commits"];
                
                NSMutableArray *commits = [NSMutableArray array];
                for (NSDictionary *rawCommit in array) {
                    [commits addObject:[[[GHCommit alloc] initWithRawDictionary:rawCommit] autorelease] ];
                }
                handler(commits, nil);
            }
        });
    });
}

+ (void)filesOnRepository:(NSString *)repository 
                   branch:(NSString *)branch 
        completionHandler:(void (^)(GHDirectory *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/json/blob/all/defunkt/facebox/master
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/blob/all/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           [branch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [[request responseString] objectFromJSONString];
                
                GHDirectory *rootDirectory = [[[GHDirectory alloc] initWithFilesDictionary:[dictionary objectForKeyOrNilOnNullObject:@"blobs"] name:@"" ] autorelease];
                
                handler(rootDirectory, nil);
            }
        });
    });
    
}

+ (void)searchRepositoriesWithSearchString:(NSString *)searchString completionHandler:(void (^)(NSArray *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/json/repos/search/ruby+testing
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/search/%@",
                                           [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [[request responseString] objectFromJSONString];
                
                NSArray *allRepos = [dictionary objectForKeyOrNilOnNullObject:@"repositories"];
                NSMutableArray *repos = [NSMutableArray arrayWithCapacity:[allRepos count] ];
                
                for (NSDictionary *rawRepo in allRepos) {
                    [repos addObject:[[[GHRepository alloc] initWithRawDictionary:rawRepo] autorelease] ];
                }
                
                handler(repos, nil);
            }
        });
    });
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.creationDate = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.desctiptionRepo = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.fork = [rawDictionary objectForKeyOrNilOnNullObject:@"fork"];
        self.forks = [rawDictionary objectForKeyOrNilOnNullObject:@"forks"];
        self.hasDownloads = [rawDictionary objectForKeyOrNilOnNullObject:@"has_downloads"];
        self.hasIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"has_issues"];
        self.hasWiki = [rawDictionary objectForKeyOrNilOnNullObject:@"has_wiki"];
        self.homePage = [rawDictionary objectForKeyOrNilOnNullObject:@"homepage"];
        self.integrateBranch = [rawDictionary objectForKeyOrNilOnNullObject:@"integrate_branch"];
        self.language = [rawDictionary objectForKeyOrNilOnNullObject:@"language"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.openIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"open_issues"];
        self.owner = [rawDictionary objectForKeyOrNilOnNullObject:@"owner"];
        self.parent = [rawDictionary objectForKeyOrNilOnNullObject:@"parent"];
        self.private = [rawDictionary objectForKeyOrNilOnNullObject:@"private"];
        self.pushedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"pushed_at"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        self.source = [rawDictionary objectForKeyOrNilOnNullObject:@"source"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.watchers = [rawDictionary objectForKeyOrNilOnNullObject:@"watchers"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_creationDate release];
    [_desctiptionRepo release];
    [_fork release];
    [_forks release];
    [_hasDownloads release];
    [_hasIssues release];
    [_hasWiki release];
    [_homePage release];
    [_integrateBranch release];
    [_language release];
    [_name release];
    [_openIssues release];
    [_owner release];
    [_parent release];
    [_private release];
    [_pushedAt release];
    [_size release];
    [_source release];
    [_URL release];
    [_watchers release];
    
    [super dealloc];
}

@end
