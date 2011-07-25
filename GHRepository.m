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
                NSDictionary *dict = NSObjectExpectedClass([jsonString objectFromJSONString], NSDictionary.class);
                handler(NSObjectExpectedClass([dict objectForKey:@"delete_token"], NSString.class), nil);
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
                NSDictionary *dictionary = NSObjectExpectedClass([[request responseString] objectFromJSONString], NSDictionary.class);
                
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
                NSDictionary *dictionary = NSObjectExpectedClass([[request responseString] objectFromJSONString], NSDictionary.class);
                
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
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    [aCoder encodeObject:self.desctiptionRepo forKey:@"desctiptionRepo"];
    [aCoder encodeObject:self.fork forKey:@"fork"];
    [aCoder encodeObject:self.forks forKey:@"forks"];
    [aCoder encodeObject:self.hasDownloads forKey:@"hasDownloads"];
    [aCoder encodeObject:self.hasIssues forKey:@"hasIssues"];
    [aCoder encodeObject:self.hasWiki forKey:@"hasWiki"];
    [aCoder encodeObject:self.homePage forKey:@"homePage"];
    [aCoder encodeObject:self.integrateBranch forKey:@"integrateBranch"];
    [aCoder encodeObject:self.language forKey:@"language"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.openIssues forKey:@"openIssues"];
    [aCoder encodeObject:self.owner forKey:@"owner"];
    [aCoder encodeObject:self.parent forKey:@"parent"];
    [aCoder encodeObject:self.private forKey:@"private"];
    [aCoder encodeObject:self.pushedAt forKey:@"pushedAt"];
    [aCoder encodeObject:self.size forKey:@"size"];
    [aCoder encodeObject:self.source forKey:@"source"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeObject:self.watchers forKey:@"watchers"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        self.desctiptionRepo = [aDecoder decodeObjectForKey:@"desctiptionRepo"];
        self.fork = [aDecoder decodeObjectForKey:@"fork"];
        self.forks = [aDecoder decodeObjectForKey:@"forks"];
        self.hasDownloads = [aDecoder decodeObjectForKey:@"hasDownloads"];
        self.hasIssues = [aDecoder decodeObjectForKey:@"hasIssues"];
        self.hasWiki = [aDecoder decodeObjectForKey:@"hasWiki"];
        self.homePage = [aDecoder decodeObjectForKey:@"homePage"];
        self.integrateBranch = [aDecoder decodeObjectForKey:@"integrateBranch"];
        self.language = [aDecoder decodeObjectForKey:@"language"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.openIssues = [aDecoder decodeObjectForKey:@"openIssues"];
        self.owner = [aDecoder decodeObjectForKey:@"owner"];
        self.parent = [aDecoder decodeObjectForKey:@"parent"];
        self.private = [aDecoder decodeObjectForKey:@"private"];
        self.pushedAt = [aDecoder decodeObjectForKey:@"pushedAt"];
        self.size = [aDecoder decodeObjectForKey:@"size"];
        self.source = [aDecoder decodeObjectForKey:@"source"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.watchers = [aDecoder decodeObjectForKey:@"watchers"];
    }
    return self;
}

@end
