//
//  UITableViewAlert.m
//  ExampleApp
//
//  Created by Oliver Letterer on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "GHTableViewAlertViewTableViewBackgroundView.h"
#import "GHTableViewAlertViewTableViewCell.h"


@implementation GHTableViewAlertView

@synthesize tableView=_tableView;

#pragma mark -
#pragma mark instance methods

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithTitle:title message:@"\n\n\n\n\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11.0f, 50.0f, 261.0f, 147.0f) style:UITableViewStylePlain];
		_tableView.layer.cornerRadius = 5.0f;
		_tableView.separatorColor = [UIColor colorWithWhite:175.0f/255.0f alpha:0.0f];
		_tableView.backgroundColor = [UIColor whiteColor];
		[self addSubview:_tableView];
        _tableView.backgroundView = [[GHTableViewAlertViewTableViewBackgroundView alloc] initWithFrame:_tableView.bounds];
		
		UIColor *darkShadowColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		UIColor *lightShadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
		
		CAGradientLayer *layer = [CAGradientLayer layer];
		layer.colors = [NSArray arrayWithObjects:
						(__bridge id)darkShadowColor.CGColor, (__bridge id)lightShadowColor.CGColor,
						(__bridge id)lightShadowColor.CGColor, (__bridge id)darkShadowColor.CGColor, 
						nil];
		layer.locations = [NSArray arrayWithObjects:
						   [NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.05f],
						   [NSNumber numberWithFloat:0.98f], [NSNumber numberWithFloat:1.0f],
						   nil];
		layer.frame = _tableView.frame;
		layer.cornerRadius = _tableView.layer.cornerRadius;
		[self.layer addSublayer:layer];
    }
    return self;
}

@end
