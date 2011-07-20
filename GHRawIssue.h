//
//  GHRawIssue.h
//  iGithub
//
//  Created by Oliver Letterer on 10.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHRawIssue : NSObject <NSCoding> {
@private
    NSString *_gravatarID;
    NSNumber *_position;
    NSNumber *_number;
    NSNumber *_votes;
    NSString *_creationDate;
    NSNumber *_comments;
    NSString *_body;
    NSString *_title;
    NSString *_updatedAd;
    NSString *_closedAd;
    NSString *_user;
    NSString *_labelsJSON;
    NSString *_state;
}

@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSNumber *position;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSNumber *votes;
@property (nonatomic, copy) NSString *creationDate;
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *updatedAd;
@property (nonatomic, copy) NSString *closedAd;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *labelsJSON;
@property (nonatomic, copy) NSString *state;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
