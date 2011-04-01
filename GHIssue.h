//
//  GHIssue.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GHIssue : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * gravatarID;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * votes;
@property (nonatomic, retain) NSString * creationDate;
@property (nonatomic, retain) NSNumber * comments;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * updatedAd;
@property (nonatomic, retain) NSString * closedAd;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * labelsJSON;
@property (nonatomic, retain) NSString * state;

@property (nonatomic, retain) NSDate * lastUpdateDate;
@property (nonatomic, retain) NSString * repository;

- (void)updateWithRawDictionary:(NSDictionary *)rawDictionary onRepository:(NSString *)repository;

+ (void)issueOnRepository:(NSString *)repositoriy 
          withNumber:(NSNumber *)number 
       loginUsername:(NSString *)loginUsername 
            password:(NSString *)password completionHandler:(void (^)(GHIssue *issue, NSError *error))handler;

+ (GHIssue *)issueFromDatabaseOnRepository:(NSString *)repositoriy 
                           withNumber:(NSNumber *)number;

@end
