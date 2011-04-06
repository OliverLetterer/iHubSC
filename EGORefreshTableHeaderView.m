//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+Nibware.h"


#define kReleaseToReloadStatus	0
#define kPullToReloadStatus		1
#define kLoadingStatus			2


@implementation EGORefreshTableHeaderView

@synthesize isFlipped, lastUpdatedDate;

@synthesize lastUpdatedLabel=_lastUpdatedLabel, statusLabel=_statusLabel, arrowImage=_arrowImage, activityView=_activityView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor colorWithWhite:0.925f alpha:1.0f];
		_lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, 320.0f, 20.0f)];
		_lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		_lastUpdatedLabel.textColor = [UIColor grayColor];
		_lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_lastUpdatedLabel.backgroundColor = self.backgroundColor;
		_lastUpdatedLabel.opaque = YES;
		_lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_lastUpdatedLabel];
        
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, 320.0f, 20.0f)];
		_statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		_statusLabel.textColor = [UIColor grayColor];
		_statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_statusLabel.backgroundColor = self.backgroundColor;
		_statusLabel.opaque = YES;
		_statusLabel.textAlignment = UITextAlignmentCenter;
		[self setStatus:kPullToReloadStatus];
		[self addSubview:_statusLabel];
        
		UIImage *refreshArrow = [UIImage imageNamed:@"PullToRefreshArrow.png"];
		_arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(25.0f, frame.size.height - 52.0f, refreshArrow.size.width, refreshArrow.size.height)];
		_arrowImage.image = refreshArrow;
		[_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		[self addSubview:_arrowImage];
        
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		_activityView.hidesWhenStopped = YES;
		[self addSubview:_activityView];
		isFlipped = NO;
        [self flipImageAnimated:NO];
    }
    return self;
}

- (void)flipImageAnimated:(BOOL)animated {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animated ? .18 : 0.0];
	[_arrowImage layer].transform = isFlipped ? 
	CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : 
	CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
	isFlipped = !isFlipped;
}

- (void)setLastUpdatedDate:(NSDate *)newDate {
	if (newDate) {
		if (lastUpdatedDate != newDate) {
			[lastUpdatedDate release];
		}
		lastUpdatedDate = [newDate retain];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [lastUpdatedDate prettyDate]];
	} else {
		lastUpdatedDate = nil;
		_lastUpdatedLabel.text = @"Last Updated: Never";
	}
}

- (void)setStatus:(int)status {
	switch (status) {
		case kReleaseToReloadStatus:
			_statusLabel.text = @"Release to refresh...";
			break;
		case kPullToReloadStatus:
			_statusLabel.text = @"Pull down to refresh...";
			break;
		case kLoadingStatus:
			_statusLabel.text = @"Loading...";
			break;
		default:
			break;
	}
}

- (void)toggleActivityView:(BOOL)isON {
	if (!isON) {
		[_activityView stopAnimating];
		_arrowImage.hidden = NO;
	} else {
		[_activityView startAnimating];
		_arrowImage.hidden = YES;
		[self setStatus:kLoadingStatus];
	}
}

- (void)dealloc {
    [_lastUpdatedLabel release];
    [_statusLabel release];
    [_arrowImage release];
    [_activityView release];
    
    [super dealloc];
}

@end