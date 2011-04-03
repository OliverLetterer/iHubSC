//
//  GHRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRepository.h"
#import "GithubAPI.h"

@implementation GHRepository

@synthesize creationDate=_creationDate, desctiptionRepo=_desctiptionRepo, fork=_fork, forks=_forks, hasDownloads=_hasDownloads, hasIssues=_hasIssues, hasWiki=_hasWiki, homePage=_homePage, integrateBranch=_integrateBranch, language=_language, name=_name, openIssues=_openIssues, owner=_owner, private=_private, pushedAt=_pushedAt, size=_size, URL=_URL, watchers=_watchers;


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
