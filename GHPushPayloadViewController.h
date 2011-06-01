//
//  GHPushPayloadViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@interface GHPushPayloadViewController : GHTableViewController {
@private
    GHPushPayload *_payload;
    NSString *_repository;
}

@property (nonatomic, retain) GHPushPayload *payload;
@property (nonatomic, copy) NSString *repository;

- (id)initWithPayload:(GHPushPayload *)payload onRepository:(NSString *)repository;

- (void)cachePayloadHeights;

@end
