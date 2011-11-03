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

#warning get rid of this class. No longer needed because of new Events API.
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
