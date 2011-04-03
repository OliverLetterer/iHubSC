//
//  GHGistEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithActor.h"

@interface GHGistEventPayload : GHPayloadWithActor {
    NSString *_action;
    NSString *_descriptionGist;
    NSString *_name;
    NSString *_snippet;
    NSString *_URL;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *descriptionGist;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *snippet;
@property (nonatomic, copy) NSString *URL;

@end
