//
//  WAAttributesMarkdownFormatter.h
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "WAMarkdownParser.h"
#import "WAHTMLMarkdownFormatter.h"

@interface WAAttributesMarkdownFormatter : WAHTMLMarkdownFormatter {
    NSString *_defaultFontSize;
    NSString *_defaultFontColor;
}

@property (nonatomic, copy) NSString *defaultFontSize;
@property (nonatomic, copy) NSString *defaultFontColor;


@end
