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

@synthesize repositoryLabel=_repositoryLabel;

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
    
    self.repositoryLabel.frame = CGRectMake(76.0f, CGRectGetHeight(self.contentView.bounds)-25.0f, CGRectGetWidth(self.contentView.bounds) - 76.0f - 3.0f, 21.0f);
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
    
    [super dealloc];
}

@end
