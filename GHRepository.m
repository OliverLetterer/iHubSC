//
//  GHRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRepository.h"


@implementation GHRepository

@synthesize creationDate=_creationDate, desctiptionRepo=_desctiptionRepo, fork=_fork, forks=_forks, hasDownloads=_hasDownloads, hasIssues=_hasIssues, hasWiki=_hasWiki, homePage=_homePage, integrateBranch=_integrateBranch, language=_language, name=_name, openIssues=_openIssues, owner=_owner, private=_private, pushedAt=_pushedAt, size=_size, URL=_URL, watchers=_watchers;


#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.creationDate = [rawDictionary objectForKey:@"created_at"];
        self.desctiptionRepo = [rawDictionary objectForKey:@"description"];
        self.fork = [rawDictionary objectForKey:@"fork"];
        self.forks = [rawDictionary objectForKey:@"forks"];
        self.hasDownloads = [rawDictionary objectForKey:@"has_downloads"];
        self.hasIssues = [rawDictionary objectForKey:@"has_issues"];
        self.hasWiki = [rawDictionary objectForKey:@"has_wiki"];
        self.homePage = [rawDictionary objectForKey:@"homepage"];
        self.integrateBranch = [rawDictionary objectForKey:@"integrate_branch"];
        self.language = [rawDictionary objectForKey:@"language"];
        self.name = [rawDictionary objectForKey:@"name"];
        self.openIssues = [rawDictionary objectForKey:@"open_issues"];
        self.owner = [rawDictionary objectForKey:@"owner"];
        self.private = [rawDictionary objectForKey:@"private"];
        self.pushedAt = [rawDictionary objectForKey:@"pushed_at"];
        self.size = [rawDictionary objectForKey:@"size"];
        self.URL = [rawDictionary objectForKey:@"url"];
        self.watchers = [rawDictionary objectForKey:@"watchers"];
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
