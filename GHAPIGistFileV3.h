//
//  GHAPIGistFileV3.h
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIGistFileV3 : NSObject {
@private
    NSString *_filename;
    NSNumber *_size;
    NSString *_URL;
    NSString *_content;
}

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *content;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

@end
