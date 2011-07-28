//
//  Extras.h
//  WebServer
//
//  Created by Tomas Franzén on 2010-12-08.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

@interface NSString (WAExtras)
- (NSString*)HTMLEscapedString;
- (NSString*)HTML;
- (NSString*)stringByEnforcingCharacterSet:(NSCharacterSet*)set;
@end
