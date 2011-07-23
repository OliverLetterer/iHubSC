//
//  GHAPIIssueCommentV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIUserV3;

@interface GHAPIIssueCommentV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    NSString *_body;
    GHAPIUserV3 *_user;
    NSString *_createdAt;
    NSString *_updatedAt;
    
    NSAttributedString *_attributedBody;
    NSAttributedString *_selectedAttributedBody;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *body;

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *updatedAt;

@property (nonatomic, retain) NSAttributedString *attributedBody;
@property (nonatomic, retain) NSAttributedString *selectedAttributedBody;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

- (NSComparisonResult)compare:(NSObject *)anObject;

@end
