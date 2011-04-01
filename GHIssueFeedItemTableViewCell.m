//
//  GHIssueFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueFeedItemTableViewCell.h"


@implementation GHIssueFeedItemTableViewCell

@synthesize gravatarImageView=_gravatarImageView, actorLabel=_actorLabel, statusLabel=_statusLabel, repositoryLabel=_repositoryLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"GHIssueFeedItemTableViewCellContentView" owner:self options:nil];
        [self.contentView addSubview:_myContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self.statusLabel setHighlighted:selected];
    [self.repositoryLabel setHighlighted:selected];
    [self.actorLabel setHighlighted:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self.statusLabel setHighlighted:highlighted];
    [self.repositoryLabel setHighlighted:highlighted];
    [self.actorLabel setHighlighted:highlighted];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _myContentView.frame = self.contentView.bounds;
    
//    CGRect repoFrame = self.repositoryLabel.frame;
//    repoFrame.origin.y = _myContentView.bounds.size.height - 21.0;
//    self.repositoryLabel.frame = repoFrame;
}

+ (CGFloat)height {
    return 71.0;
}

#pragma mark - Memory management

- (void)dealloc {
    [_myContentView release];
    [_gravatarImageView release];
    [_actorLabel release];
    [_statusLabel release];
    [_repositoryLabel release];
    [super dealloc];
}

@end
