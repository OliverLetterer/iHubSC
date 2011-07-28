//
//  UITableViewAlertViewTableViewCellSeperatorView.m
//  Installous
//
//  Created by Oliver Letterer on 31.01.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewAlertViewTableViewCellSeperatorView.h"


@implementation GHTableViewAlertViewTableViewCellSeperatorView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	[[UIColor clearColor] setFill];
	CGContextFillRect(ctx, self.bounds);
	
	[[UIColor lightGrayColor] setStroke];
	CGContextStrokeRect(ctx, CGRectMake(0.0, -0.5, self.bounds.size.width, 1.0));
	
	[[UIColor whiteColor] setStroke];
	CGContextStrokeRect(ctx, CGRectMake(0.0, 1.5, self.bounds.size.width, 1.0));
}

@end
