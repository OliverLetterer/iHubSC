//
//  GHNewsFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedItemTableViewCell.h"
#import "UITableViewCell+Background.h"
#import <QuartzCore/QuartzCore.h>

#define GHNewsFeedItemTableViewCellRepositoryLabelHeight 21.0
#define GHNewsFeedItemTableViewCellRepositoryLabelBottomOffset 3.0


@implementation GHNewsFeedItemTableViewCell

@synthesize activityIndicatorView=_activityIndicatorView, backgroundGradientLayer=_backgroundGradientLayer;

#pragma mark - setters and getters

- (UILabel *)titleLabel {
    return self.textLabel;
}

- (UILabel *)repositoryLabel {
    return self.detailTextLabel;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        [self.contentView addSubview:self.activityIndicatorView];
        
        // setup my views
        self.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.repositoryLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12.0];
        self.repositoryLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.repositoryLabel.highlightedTextColor = [UIColor whiteColor];
        self.repositoryLabel.textAlignment = UITextAlignmentRight;
        self.repositoryLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundGradientLayer = [CAGradientLayer layer];
        self.backgroundGradientLayer.colors = [NSArray arrayWithObjects:
                                               (id)[UIColor whiteColor].CGColor, 
                                               (id)[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor,
                                               nil];
        self.backgroundGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
        self.backgroundView = [[[UIView alloc] init] autorelease];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        [self.backgroundView.layer addSublayer:self.backgroundGradientLayer];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setBackgroundShadowHeight:5.0];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setBackgroundShadowHeight:5.0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0, 8.0, 56.0, 56.0);
    self.titleLabel.frame = CGRectMake(78.0, 4.0, 222.0, 15.0);
    self.repositoryLabel.frame = CGRectMake(78.0, self.contentView.bounds.size.height - GHNewsFeedItemTableViewCellRepositoryLabelHeight - GHNewsFeedItemTableViewCellRepositoryLabelBottomOffset, 222.0, GHNewsFeedItemTableViewCellRepositoryLabelHeight);
    
    self.activityIndicatorView.center = self.imageView.center;
    
    self.backgroundGradientLayer.frame = self.backgroundView.bounds;
    NSLog(@"%@", self.backgroundView);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    self.repositoryLabel.text = nil;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Memory management

- (void)dealloc {
    [_activityIndicatorView release];
    [_backgroundGradientLayer release];
    [super dealloc];
}

@end
