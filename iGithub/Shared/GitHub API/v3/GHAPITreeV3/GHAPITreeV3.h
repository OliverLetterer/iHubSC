//
//  GHAPITreeV3.h
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPITreeV3 : NSObject <NSCoding> {
@private
    NSString *_SHA;
    NSString *_URL;
    NSArray *_content;
}

@property (nonatomic, copy) NSString *SHA;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, retain) NSArray *content;

+ (void)contentOfBranch:(NSString *)branchHash onRepository:(NSString *)repository completionHandler:(void(^)(GHAPITreeV3 *tree, NSError *error))handler;

+ (void)treeOfCommit:(NSString *)commitID onRepository:(NSString *)repository completionHandler:(void(^)(GHAPITreeV3 *tree, NSError *error))handler;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
