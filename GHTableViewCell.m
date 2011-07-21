//
//  GHNewsFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewCell.h"
#import "UITableViewCell+Background.h"
#import <QuartzCore/QuartzCore.h>

#define GHNewsFeedItemTableViewCellRepositoryLabelHeight 21.0
#define GHNewsFeedItemTableViewCellRepositoryLabelBottomOffset 3.0


@implementation GHTableViewCell

@synthesize timeLabel=_timeLabel;

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
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.timeLabel.font = [UIFont systemFontOfSize:12.0f];
        self.timeLabel.textColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
        self.timeLabel.highlightedTextColor = [UIColor whiteColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0, 8.0, 56.0, 56.0);
    [self.timeLabel sizeToFit];
    CGFloat width = CGRectGetWidth(self.timeLabel.bounds);
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds)-width, 4.0f, width, CGRectGetHeight(self.timeLabel.bounds));
    self.titleLabel.frame = CGRectMake(78.0, 4.0, CGRectGetWidth(self.contentView.bounds)-width-78.0f, 15.0);
    self.repositoryLabel.frame = CGRectMake(78.0, self.contentView.bounds.size.height - GHNewsFeedItemTableViewCellRepositoryLabelHeight - GHNewsFeedItemTableViewCellRepositoryLabelBottomOffset, 222.0, GHNewsFeedItemTableViewCellRepositoryLabelHeight);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    self.repositoryLabel.text = nil;
    self.timeLabel.text = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [_timeLabel release];
    
    [super dealloc];
}

@end
