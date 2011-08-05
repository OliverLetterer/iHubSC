//
//  GHAPILabelV3.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPILabelV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    NSString *_name;
    NSString *_colorString;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *colorString;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

- (BOOL)isEqualToLabel:(GHAPILabelV3 *)label;

@end
