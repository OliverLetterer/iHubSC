//
//  GHAPIMilestoneV3TableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIMilestoneV3TableViewCell.h"


@implementation GHAPIMilestoneV3TableViewCell

@synthesize progressView=_progressView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        _progressView = [[INProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 10.0)];
        self.detailTextLabel.text = @" ";
        [self.contentView addSubview:_progressView];
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
    CGRect frame = self.detailTextLabel.frame;
    frame.size.width = self.contentView.bounds.size.width - frame.origin.x - 10.0f;
    frame.size.height = self.progressView.frame.size.height;
    self.progressView.frame = frame;
    
    CGPoint center = self.progressView.center;
    center.y = self.detailTextLabel.center.y - 5.0;
    self.progressView.center = center;
    
    center = self.textLabel.center;
    center.y -= 5.0f;
    self.textLabel.center = center;
    
    center = self.detailTextLabel.center;
    center.y += 12.0f;
    self.detailTextLabel.center = center;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_progressView release];
    
    [super dealloc];
}

@end
