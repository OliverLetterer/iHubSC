//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;
@synthesize lastUpdatedLabel=_lastUpdatedLabel, statusLabel=_statusLabel, arrowImage=_arrowImage, activityView=_activityView;
@synthesize defaultInset=_defaultInset;

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
        self.lastUpdatedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)] 
                                 autorelease];
		self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		self.lastUpdatedLabel.textColor = [UIColor colorWithWhite:0.25f alpha:1.0];
		self.lastUpdatedLabel.shadowColor = [UIColor whiteColor];
		self.lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		self.lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.lastUpdatedLabel];
		
		self.statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)] 
                            autorelease];
		self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		self.statusLabel.textColor = [UIColor colorWithWhite:0.25f alpha:1.0];
		self.statusLabel.shadowColor = [UIColor whiteColor];
		self.statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.statusLabel.backgroundColor = [UIColor clearColor];
		self.statusLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.statusLabel];
		
		self.arrowImage = [CALayer layer];
		self.arrowImage.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		self.arrowImage.contentsGravity = kCAGravityResizeAspect;
		self.arrowImage.contents = (id)[UIImage imageNamed:@"PullToRefreshArrow.png"].CGImage;
		self.arrowImage.contentsScale = [[UIScreen mainScreen] scale];
		[self.layer addSublayer:self.arrowImage];
		
        self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		self.activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:self.activityView];
		
		[self setState:EGOOPullRefreshNormal];
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	NSDate *date = [self.delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:NSLocalizedString(@"MM/dd/yyyy hh:mm:ss", @"")];
    _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@", @""), [formatter stringFromDate:date]];
}

- (void)setState:(EGOPullRefreshState)aState{
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		
        CGFloat dragDistance = -65.0f - _defaultInset.top;
        CGFloat min = _defaultInset.top;
        
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > dragDistance && scrollView.contentOffset.y < min && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < dragDistance && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != min) {
			scrollView.contentInset = _defaultInset;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	
    CGFloat dragDistance = -65.0f - _defaultInset.top;
    
	if (scrollView.contentOffset.y <= dragDistance && !_loading) {
        [self.delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:_defaultInset];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [_lastUpdatedLabel release];
    [_statusLabel release];
    [_arrowImage release];
    [_activityView release];
    [super dealloc];
}


@end
