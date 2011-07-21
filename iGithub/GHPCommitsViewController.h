//
//  GHPCommitsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDataArrayViewController.h"

typedef enum {
    GHPCommitsViewControllerContentTypeUsualCommits = 0,
    GHPCommitsViewControllerContentTypePushPayload
} GHPCommitsViewControllerContentType;

@interface GHPCommitsViewController : GHPDataArrayViewController <NSCoding> {
@private
    NSString *_repository;
    NSString *_branchHash;
    GHPushPayload *_pushPayload;
    
    GHPCommitsViewControllerContentType _contentType;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *branchHash;
@property (nonatomic, retain) GHPushPayload *pushPayload;

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash;

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash;
- (id)initWithRepository:(NSString *)repository pushPayload:(GHPushPayload *)pushPayload;

@end
