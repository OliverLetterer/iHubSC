//
//  GHAPICommitV3.h
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIUserV3, GHAPITreeInfoV3;

@interface GHAPICommitV3 : NSObject {
@private
    NSString *_SHA;
    NSString *_URL;
    GHAPIUserV3 *_author;
    GHAPIUserV3 *_committer;
    NSString *_message;
    GHAPITreeInfoV3 *_tree;
    NSArray *_parents;
}

@property (nonatomic, copy) NSString *SHA;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, retain) GHAPIUserV3 *author;
@property (nonatomic, retain) GHAPIUserV3 *committer;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) GHAPITreeInfoV3 *tree;
@property (nonatomic, retain) NSArray *parents;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

//#warning commit API only displays that files are modified, no way to tell if they where added or removed
+ (void)singleCommitOnRepository:(NSString *)repository branchSHA:(NSString *)branchSHA completionHandler:(void (^)(GHAPICommitV3 *commit, NSError *error))handler;

@end
