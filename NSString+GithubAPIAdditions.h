//
//  NSString+GithubAPIAdditions.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (GHAPIDateFormatting)
@property (nonatomic, readonly) NSDate *dateFromGithubAPIDateString;
@property (nonatomic, readonly) NSString *gravarID;
@property (nonatomic, readonly) NSString *prettyTimeIntervalSinceNow;
@end


@interface NSString (GHAPIHTTPParsing)
@property (nonatomic, readonly) NSUInteger nextPage;
@end


@interface NSString (GHAPIColorParsing)
@property (nonatomic, readonly) UIColor *colorFromAPIColorString;
@end


@interface NSString (Parsing)
- (NSString *)substringBetweenLeftBounds:(NSString *)leftBounds andRightBounds:(NSString *)rightBounds;
@end


extern NSString *const kGHNSStringMarkdownStyleFull;

@interface NSString (GHMarkdownParsing)
@property (nonatomic, readonly) NSString *HTMLMarkdownFormattedString;
- (NSString *)stringFromMarkdownStyle:(NSString *)markdownStyle;
@end