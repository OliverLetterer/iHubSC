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
}

@property (nonatomic, retain) GHPushPayload *payload;

- (id)initWithPayload:(GHPushPayload *)payload;

- (void)cachePayloadHeights;

@end
