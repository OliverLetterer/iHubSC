//
//  WAAttributesMarkdownFormatter.m
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "WAAttributesMarkdownFormatter.h"
#import "WAFoundationExtras.h"

@implementation WAAttributesMarkdownFormatter
@synthesize defaultFontSize=_defaultFontSize, defaultFontColor=_defaultFontColor;

- (NSString*)parser:(WAMarkdownParser*)parser stringForParagraph:(NSString*)content {
	return [NSString stringWithFormat:@"<p style=\"color:%@;font-family:Helvetica;font-size:%@; text-shadow:0px 0.5px #FFF\">%@</p>", self.defaultFontColor, self.defaultFontSize, content];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForBlockQuote:(NSString*)content {
	return [NSString stringWithFormat:@"<blockquote style=\"margin:1em 0;border-left:5px solid #ddd;padding-left:.6em;color:#555;\">%@</blockquote>", content];	
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForInlineCode:(NSString*)code {
	return [NSString stringWithFormat:@"<code style=\"font-size:12px;color:#444;padding:0 .2em;border:1px solid #dedede;\">%@</code>", [code HTMLEscapedString]];	
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForBlockCode:(NSString*)code {
	return [NSString stringWithFormat:@"<pre style=\"padding:0;font-size:12px;\"><code style=\"font-size:12px;color:#444;padding:0 .2em;border:1px solid #dedede;\">%@</code></pre>", [code HTMLEscapedString]];	
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForInlineHTML:(NSString*)HTML {
	return [NSString stringWithFormat:@"%@", HTML];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForBlockHTML:(NSString*)HTML {
	return [NSString stringWithFormat:@"<div style=\"color:%@;font-family:Helvetica;font-size:%@; text-shadow:0px 0.5px #FFF\">%@</div>", self.defaultFontColor, self.defaultFontSize, HTML];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForList:(NSString*)content ordered:(BOOL)orderedList {
	NSString *element = (orderedList ? @"ol" : @"ul");
	return [NSString stringWithFormat:@"<%@ style=\"color:%@;font-family:Helvetica;font-size:%@; text-shadow:0px 0.5px #FFF\">%@</%@>", element, self.defaultFontColor, self.defaultFontSize, content, element];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForListItem:(NSString*)content containingBlock:(BOOL)isBlock {
	return [NSString stringWithFormat:@"<li style=\"color:%@;font-family:Helvetica;font-size:%@; text-shadow:0px 0.5px #FFF\">%@</li>", self.defaultFontColor, self.defaultFontSize, content];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForHeading:(NSString*)heading level:(NSUInteger)level {
	return [NSString stringWithFormat:@"<h%d style=\"color:%@;font-family:Helvetica;text-shadow:0px 0.5px #FFF\">%@</h%d>", (int)level, self.defaultFontColor, heading, (int)level];	
}

- (NSString*)stringForHorizontalRuleWithParser:(WAMarkdownParser*)parser {
	return @"<hr/>";
}

- (NSString*)stringForLinebreakWithParser:(WAMarkdownParser*)parser {
	return @"<br/>";
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForLink:(NSString*)target title:(NSString*)title content:(NSString*)content {
	title = title ? [NSString stringWithFormat:@" title=\"%@\"", title] : @"";
	return [NSString stringWithFormat:@"<a href=\"%@\"%@>%@</a>", target, title, content];	
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForImage:(NSString*)src title:(NSString*)title alternativeText:(NSString*)alt {
    title = title ? title : @"Image";
	return [NSString stringWithFormat:@"<a href=\"%@\">Image</a>", src, title];
}

- (NSString*)parser:(WAMarkdownParser*)parser stringForEmphasis:(NSString*)content strength:(NSUInteger)level character:(unichar)c {
	switch(level) {
		case 1: return [NSString stringWithFormat:@"<em>%@</em>", content];
		default: 
		case 2: return [NSString stringWithFormat:@"<strong>%@</strong>", content];
	}
}

- (id)init {
    if (self = [super init]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.defaultFontSize = @"14px";
            self.defaultFontColor = @"rgb(127,127,127)";
        } else {
            self.defaultFontSize = @"12px";
            self.defaultFontColor = @"rgb(64,64,64)";
        }
    }
    return self;
}

- (void)dealloc {
    [_defaultFontSize release];
    [_defaultFontColor release];
    
    [super dealloc];
}

@end
