//
//  GHPullToReleaseTableHeaderView.m
//  iGithub
//
//  Created by me on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullToReleaseTableHeaderView.h"

static CGFloat const kGHPullToReleaseTableHeaderViewFlipAnimationDuration = 0.2f;

CGFloat const kGHPullToReleaseTableHeaderViewPreferedHeaderHeight = 60.0f;

@implementation GHPullToReleaseTableHeaderView

@synthesize lastUpdateLabel=_lastUpdateLabel, statusLabel=_statusLabel, arrowImageLayer=_arrowImageLayer, activityIndicatorView=_activityIndicatorView;
@synthesize lastUpdateDate=_lastUpdateDate;
@synthesize state=_state;

#pragma mark - setters and getetrs

- (void)setState:(GHPullToReleaseTableHeaderViewState)state {
    if (_state != state) {
        _state = state;
        
        switch (state) {
            case GHPullToReleaseTableHeaderViewStateNormal:
                // switching state to normal
                
                self.statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
                self.arrowImageLayer.hidden = NO;
                [self.activityIndicatorView stopAnimating];
                
                [CATransaction begin];
                [CATransaction setAnimationDuration:kGHPullToReleaseTableHeaderViewFlipAnimationDuration];
                self.arrowImageLayer.transform = CATransform3DIdentity;
                [CATransaction commit];
                
                break;
                
            case GHPullToReleaseTableHeaderViewStateDraggedDown:
                
                self.statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
                
                [self.activityIndicatorView stopAnimating];
                self.arrowImageLayer.hidden = NO;
                
                [CATransaction begin];
                [CATransaction setAnimationDuration:kGHPullToReleaseTableHeaderViewFlipAnimationDuration];
                self.arrowImageLayer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
                
                break;
                
            case GHPullToReleaseTableHeaderViewStateLoading:
                
                self.statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
                [self.activityIndicatorView startAnimating];
                
                self.arrowImageLayer.hidden = YES;
                
                break;
            default:
                break;
        }
    }
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate {
    if (_lastUpdateDate != lastUpdateDate || lastUpdateDate == nil) {
        _lastUpdateDate = lastUpdateDate;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:NSLocalizedString(@"MM/dd/yyyy hh:mm:ss", @"")];
        
        NSString *formattedDateString = nil;
        if (!_lastUpdateDate) {
            formattedDateString = NSLocalizedString(@"Never", @"");
        } else {
            formattedDateString = [formatter stringFromDate:_lastUpdateDate];
        }
        
        _lastUpdateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@", @""), formattedDateString];
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		self.lastUpdateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.lastUpdateLabel.font = [UIFont systemFontOfSize:12.0f];
		self.lastUpdateLabel.textColor = [UIColor colorWithWhite:0.95f alpha:1.0];
		self.lastUpdateLabel.shadowColor = [UIColor grayColor];
		self.lastUpdateLabel.shadowOffset = CGSizeMake(-1.0f, 1.0f);
		self.lastUpdateLabel.backgroundColor = [UIColor clearColor];
		self.lastUpdateLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.lastUpdateLabel];
		
		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		self.statusLabel.textColor = [UIColor colorWithWhite:0.95f alpha:1.0];
		self.statusLabel.shadowColor = [UIColor grayColor];
		self.statusLabel.shadowOffset = CGSizeMake(-1.0f, 1.0f);
		self.statusLabel.backgroundColor = [UIColor clearColor];
		self.statusLabel.textAlignment = UITextAlignmentCenter;
        self.statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
		[self addSubview:self.statusLabel];
		
		self.arrowImageLayer = [CALayer layer];
		self.arrowImageLayer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		self.arrowImageLayer.contentsGravity = kCAGravityCenter;
		self.arrowImageLayer.contents = (__bridge id)[UIImage imageNamed:@"PullToRefreshArrow.png"].CGImage;
		self.arrowImageLayer.contentsScale = [[UIScreen mainScreen] scale];
		[self.layer addSublayer:self.arrowImageLayer];
		
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.activityIndicatorView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        self.activityIndicatorView.hidesWhenStopped = YES;
		[self addSubview:self.activityIndicatorView];
        
        self.state = GHPullToReleaseTableHeaderViewStateNormal;
        self.lastUpdateDate = nil;
    }
    return self;
}

@end
