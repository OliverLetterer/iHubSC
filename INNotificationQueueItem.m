//
//  INNotificationQueueItem.m
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "INNotificationQueueItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation INNotificationQueueItem

@synthesize titleLabel=_titleLabel, descriptionLabel=_descriptionLabel, imageView=_imageView, removeStyle=_removeStyle;

+ (id)itemWithStyle:(INNotificationQueueItemStyle)style {
	INNotificationQueueItem *n = [[INNotificationQueueItem alloc] initWithStyle:style];
	return [n autorelease];
}

- (id)initWithStyle:(INNotificationQueueItemStyle)style {
	if ((self = [super init])) {
		_style = style;
		switch (style) {
			case INNotificationQueueItemStyleSmallWithText:
				// normal style
				self.frame = CGRectMake(0, 0, 200, 75);
				self.backgroundColor = [UIColor clearColor];
				
				UIView *backgroundView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
				backgroundView.backgroundColor = [UIColor blackColor];
				backgroundView.alpha = 0.45;
				backgroundView.layer.cornerRadius = 10.0;
				[self addSubview:backgroundView];
				
				// create title Label
				self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-20, 21)] autorelease];
				self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
				self.titleLabel.textColor = [UIColor whiteColor];
				self.titleLabel.textAlignment = UITextAlignmentCenter;
				self.titleLabel.backgroundColor = [UIColor clearColor];
				[self addSubview:self.titleLabel];
				
				// create description label
				self.descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 41, self.frame.size.width-20, 21)] autorelease];
				self.descriptionLabel.font = [UIFont systemFontOfSize:15];
				self.descriptionLabel.textColor = [UIColor whiteColor];
				self.descriptionLabel.textAlignment = UITextAlignmentCenter;
				self.descriptionLabel.backgroundColor = [UIColor clearColor];
				self.descriptionLabel.minimumFontSize = 8.0;
				[self addSubview: self.descriptionLabel];
				
				break;
			case INNotificationQueueItemStyleLargeWithImage:
				// large notification
				self.frame = CGRectMake(0, 0, 165, 165);
				self.backgroundColor = [UIColor clearColor];
				
				backgroundView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
				backgroundView.backgroundColor = [UIColor blackColor];
				backgroundView.alpha = 0.45;
				backgroundView.layer.cornerRadius = 10.0;
				[self addSubview:backgroundView];
				
				// create imageView
				self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-64/2, self.frame.size.height/2-64/2-10, 64, 64)] autorelease];
				self.imageView.contentMode = UIViewContentModeScaleToFill;
				self.imageView.layer.cornerRadius = 12.0;
				self.imageView.layer.masksToBounds = YES;
				[self addSubview:self.imageView];
				
				// create title label
				self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 30, self.frame.size.width-20, 21)] autorelease];
				self.titleLabel.center = CGPointMake(82, 145);
				self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
				self.titleLabel.adjustsFontSizeToFitWidth = YES;
				self.titleLabel.minimumFontSize = 12;
				self.titleLabel.textColor = [UIColor whiteColor];
				self.titleLabel.textAlignment = UITextAlignmentCenter;
				self.titleLabel.backgroundColor = [UIColor clearColor];
				[self addSubview:self.titleLabel];
				[self bringSubviewToFront:self.titleLabel];
				
				break;
			default:
				break;
		}
	}
	return self;
}

- (void)dealloc {
	[_backgroundImageView release];
	self.titleLabel = nil;
	self.descriptionLabel = nil;
	self.imageView = nil;
    [super dealloc];
}


@end
