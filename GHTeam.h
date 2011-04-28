//
//  GHTeam.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHTeam : NSObject {
@private
    NSString *_name;
    NSNumber *_ID;
    NSString *_permission;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *permission;

- (id)initWithRawDictionary:(NSDictionary *)dictionary;

- (void)deleteWithCompletionHandler:(void(^)(NSError *error))handler;
- (void)membersWithCompletionHandler:(void(^)(NSArray *members, NSError *error))handler;
- (void)deleteMember:(NSString *)login withCompletionHandler:(void(^)(NSError *error))handler;
- (void)repositoriesWithCompletionHandler:(void(^)(NSArray *repos, NSError *error))handler;
- (void)deleteRepository:(NSString *)repo withCompletionHandler:(void(^)(NSError *error))handler;

@end
