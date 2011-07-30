//
//  GHAPIMarkdownFormatter.h
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIMarkdownFormatter : NSObject {
@private
    
}

+ (NSString *)fullHTMLPageFromMarkdownString:(NSString *)markdown;

+ (NSString *)HTMLStringFromMarkdownString:(NSString *)markdown;
+ (NSString *)issueFormattedHTMLStringFromMarkdownString:(NSString *)markdown;
+ (NSString *)selectedFormattedHTMLStringFromMarkdownString:(NSString *)markdown;

@end
