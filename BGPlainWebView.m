//
//  BGPlainWebView.m
//  BGPlainWebView
//
//  Created by Geri on 2/23/11.
//  Copyright 2011 ©ompactApps. All rights reserved.
//

#import "BGPlainWebView.h"

@implementation BGPlainWebView
@synthesize backgroundColor;

-(id)initWithCoder:(NSCoder*) coder
{
    if((self = [super initWithCoder:coder])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}  

-(void)layoutSubviews
{   
    //Set the webView's background.
    [[[self subviews] lastObject] setBackgroundColor:backgroundColor]; 
    
    //Hide shadow (hide every UIImageView instance).
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = obj;
            [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = obj;
                    if (imageView.frame.size.width >= 320.0f) {
                        imageView.hidden = YES;
                    }
                }
            }];
        }
    }];
}

- (void)dealloc {
    self.backgroundColor = nil;
    [super dealloc];
}

@end