//
//  GHGistEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithActor.h"

// :user created/deleted a gist
@interface GHGistEventPayload : GHPayload {
    NSString *_action;
    NSString *_descriptionGist;
    NSString *_name;
    NSString *_snippet;
    NSString *_URL;
    
    NSString *_gistID;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *descriptionGist;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *snippet;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *gistID;

@end
