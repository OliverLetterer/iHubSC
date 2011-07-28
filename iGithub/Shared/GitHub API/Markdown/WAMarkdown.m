//
//  WAMarkdown.m
//  mdtest
//
//  Created by Tomas Franzén on 2011-02-03.
//  Copyright 2011 Lighthead Software. All rights reserved.
//

#import "WAMarkdown.h"
#import "WAHTMLMarkdownFormatter.h"

@implementation NSString (WAMarkdown)

- (NSString*)HTMLFromMarkdown {
    WAHTMLMarkdownFormatter *formatter = [[[WAHTMLMarkdownFormatter alloc] init] autorelease];
	return [formatter HTMLForMarkdown:self];
}

@end
