//
//  GHPushPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPushPayload.h"
#import "GithubAPI.h"

@implementation GHPushPayload

@synthesize head=_head, ref=_ref, commits=_commits;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadPushEvent;
}

- (NSString *)branch {
    return [[self.ref componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)previewString {
    NSMutableString *previewString = [NSMutableString string];
    
    [_commits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHCommitMessage *commit = obj;
        if (idx == 1) {
            [previewString appendFormat:@"\n- %@", commit.message];
        } else if (idx == 2) {
            NSUInteger remainingCommits = _commits.count - idx;
            if (remainingCommits == 1) {
                [previewString appendFormat:@"\n%d more commit...", remainingCommits];
            } else {
                [previewString appendFormat:@"\n%d more commits...", remainingCommits];
            }
            *stop = YES;
        } else {
            [previewString appendFormat:@"- %@", commit.message];
        }
    }];
    
    return previewString;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        self.ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        
        NSMutableArray *commitsArray = [NSMutableArray array];
        NSArray *commits = [rawDictionary objectForKeyOrNilOnNullObject:@"shas"];
        for (NSArray *commitArray in commits) {
            [commitsArray addObject:[[[GHCommitMessage alloc] initWithRawArray:commitArray] autorelease]];
        }
        self.commits = commitsArray;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_head release];
    [_ref release];
    [_commits release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.ref forKey:@"ref"];
    [aCoder encodeObject:self.commits forKey:@"commits"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.ref = [aDecoder decodeObjectForKey:@"ref"];
        self.commits = [aDecoder decodeObjectForKey:@"commits"];
    }
    return self;
}

@end
