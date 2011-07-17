//
//  GHPDefaultNewsFeedTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDefaultNewsFeedTableViewCell.h"

CGFloat const GHPDefaultNewsFeedTableViewCellHeight = 80.0f;

@implementation GHPDefaultNewsFeedTableViewCell

@synthesize repositoryLabel=_repositoryLabel, timeLabel=_timeLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        self.repositoryLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.repositoryLabel.font = [UIFont systemFontOfSize:14.0f];
        self.repositoryLabel.textColor = self.detailTextLabel.textColor;
        self.repositoryLabel.textAlignment = UITextAlignmentRight;
        self.repositoryLabel.backgroundColor = [UIColor clearColor];
        self.repositoryLabel.shadowColor = [UIColor whiteColor];
        self.repositoryLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self.contentView addSubview:self.repositoryLabel];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.timeLabel.font = [UIFont systemFontOfSize:14.0f];
        self.timeLabel.textColor = self.detailTextLabel.textColor;
        self.timeLabel.textAlignment = UITextAlignmentRight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.shadowColor = [UIColor whiteColor];
        self.timeLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self.contentView addSubview:self.timeLabel];
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
    
    CGRect bounds = self.contentView.bounds;
    [self.timeLabel sizeToFit];
    CGFloat width = CGRectGetWidth(self.timeLabel.bounds);
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(bounds) - width, self.textLabel.frame.origin.y, width, 21.0f);
    
    CGRect frame = self.textLabel.frame;
    frame.size.width = CGRectGetWidth(bounds) - frame.origin.x - width;
    self.textLabel.frame = frame;
    
    self.repositoryLabel.frame = CGRectMake(76.0f, CGRectGetHeight(bounds)-25.0f, CGRectGetWidth(bounds) - 76.0f - 3.0f, 21.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.repositoryLabel.text = nil;
}

+ (CGFloat)heightWithContent:(NSString *)content {
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(317.0f, CGFLOAT_MAX) 
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGSize repoSize = [@"name/repository" sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                     constrainedToSize:CGSizeMake(317.0f-3.0f, CGFLOAT_MAX) 
                                         lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 41.0f + 8.0f + repoSize.height;
    if (height < GHPDefaultNewsFeedTableViewCellHeight) {
        height = GHPDefaultNewsFeedTableViewCellHeight;
    }
    
    return height;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoryLabel release];
    [_timeLabel release];
    
    [super dealloc];
}

@end
