//
//  GHAPIIssueEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIUserV3;

typedef enum {
    GHAPIIssueEventTypeV3Unknown = 0,
    GHAPIIssueEventTypeV3Closed,
    GHAPIIssueEventTypeV3Reopened,
    GHAPIIssueEventTypeV3Subscribed,
    GHAPIIssueEventTypeV3Merged,
    GHAPIIssueEventTypeV3Referenced,
    GHAPIIssueEventTypeV3Mentioned,
    GHAPIIssueEventTypeV3Assigned
} GHAPIIssueEventTypeV3;

@interface GHAPIIssueEventV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    GHAPIUserV3 *_actor;
    NSString *_event;
    NSString *_commitID;
    NSString *_createdAt;
    
    GHAPIIssueEventTypeV3 _type;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, retain) GHAPIUserV3 *actor;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) NSString *commitID;
@property (nonatomic, copy) NSString *createdAt;

@property (nonatomic, readonly) GHAPIIssueEventTypeV3 type;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

- (NSComparisonResult)compare:(NSObject *)anObject;

@end
