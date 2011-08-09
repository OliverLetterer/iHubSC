//
//  UIBarButtonItem+GHEmpty.m
//  iGithub
//
//  Created by Oliver Letterer on 09.08.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "UIBarButtonItem+GHEmpty.h"

@implementation UIBarButtonItem (GHEmpty)

+ (UIBarButtonItem *)emptyBarButtonItemWithSizeOfTitle:(NSString *)title tintColor:(UIColor *)tintColor {
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:12.0f] ];
    
    return [self emptyBarButtonItemWithWidth:size.width + 24.0f tintColor:tintColor];
}

+ (UIBarButtonItem *)emptyBarButtonItemWithWidth:(CGFloat)width tintColor:(UIColor *)tintColor {
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", nil]];
    segmentControl.frame = CGRectMake(0.0f, 0.0f, width, 30.0f);
	segmentControl.momentary = YES;
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentControl.tintColor = tintColor;
	
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
	return barButtonItem;
}

@end
