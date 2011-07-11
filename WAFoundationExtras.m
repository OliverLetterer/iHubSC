//
//  Extras.m
//  WebServer
//
//  Created by Tomas Franzén on 2010-12-08.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "WAFoundationExtras.h"

@implementation NSString (WAExtras)

- (NSString*)HTMLEscapedString {
	self = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	self = [self stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	self = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	self = [self stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	return self;
}

- (NSString*)HTML {
	return [self HTMLEscapedString];
}

- (NSString*)URIEscape {
	return [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8)) autorelease];
}

- (NSString*)stringByEnforcingCharacterSet:(NSCharacterSet*)set {
	NSMutableString *string = [NSMutableString string];
	for(int i=0; i<[self length]; i++) {
		unichar c = [self characterAtIndex:i];
		if([set characterIsMember:c]) [string appendFormat:@"%C", c];
	}
	return string;
}

@end
