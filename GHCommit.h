//
//  GHCommit.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GithubAPI.h"

@interface GHCommit : NSObject {
@private
    NSString *_message;
    NSMutableArray *_added;
    NSMutableArray *_removed;
    NSMutableArray *_parents;
    NSMutableArray *_modified;
    GHUser *_author;
    NSString *_URL;
    NSString *_ID;
    NSString *_commitDate;
    NSString *_authoredDate;
    NSString *_tree;
    GHUser *_commiter;
}

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *commitDate;
@property (nonatomic, copy) NSString *authoredDate;
@property (nonatomic, copy) NSString *tree;
@property (nonatomic, retain) NSMutableArray *added;      // contains NSStrings
@property (nonatomic, retain) NSMutableArray *removed;    // contains NSStrings
@property (nonatomic, retain) NSMutableArray *parents;
@property (nonatomic, retain) NSMutableArray *modified;   // contains GHCommitFileInformation
@property (nonatomic, retain) GHUser *author;
@property (nonatomic, retain) GHUser *commiter;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)commit:(NSString *)commitID onRepository:(NSString *)repository 
                               completionHandler:(void(^)(GHCommit *commit, NSError *error))handler;

@end
