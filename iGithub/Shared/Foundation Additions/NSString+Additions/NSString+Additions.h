//
//  NSString+Additions.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSFileSize)

+ (NSString *)stringFormFileSize:(long long)fileSize;

@end

@interface NSString (CWAddition)
- (NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end;
@end
