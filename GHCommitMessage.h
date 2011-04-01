//
//  GHCommitMessage.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHCommitMessage : NSObject {
    NSString *_head;
    NSString *_EMail;
    NSString *_message;
    NSString *_name;
}

@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *name;

- (id)initWithRawArray:(NSArray *)array;

@end
