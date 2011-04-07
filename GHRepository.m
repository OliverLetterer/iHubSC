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

@synthesize creationDate=_creationDate, desctiptionRepo=_desctiptionRepo, fork=_fork, forks=_forks, hasDownloads=_hasDownloads, hasIssues=_hasIssues, hasWiki=_hasWiki, homePage=_homePage, integrateBranch=_integrateBranch, language=_language, name=_name, openIssues=_openIssues, owner=_owner, private=_private, pushedAt=_pushedAt, size=_size, URL=_URL, watchers=_watchers;

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

+ (void)repositoriesForUserNamed:(NSString *)username 
               completionHandler:(void (^)(NSArray *array, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/show/%@",
                                           [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                           ]];
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSString *jsonString = [request responseString];
        
        NSLog(@"%@", [request responseHeaders]);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *reposDictionary = [jsonString objectFromJSONString];
                NSArray *repos = [reposDictionary objectForKey:@"repositories"];
                
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[repos count] ];
                for (NSDictionary *rawRepository in repos) {
                    [array addObject:[[[GHRepository alloc] initWithRawDictionary:rawRepository] autorelease] ];
                }
                
                handler(array, nil);
            }
        });
    });
    
}

+ (void)createRepositoryWithTitle:(NSString *)title 
                      description:(NSString *)description public:(BOOL)public completionHandler:(void (^)(GHRepository *repository, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/repos/create"]];
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        
        NSLog(@"title = %@", title);
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
        self.private = [rawDictionary objectForKeyOrNilOnNullObject:@"private"];
        self.pushedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"pushed_at"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
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
    [_private release];
    [_pushedAt release];
    [_size release];
    [_URL release];
    [_watchers release];
    
    [super dealloc];
}

@end
