//
//  GHIssueFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueFeedItemTableViewCell.h"


@implementation GHIssueFeedItemTableViewCell

@synthesize gravatarImageView=_gravatarImageView, actorLabel=_actorLabel, statusLabel=_statusLabel;

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

    // Configure the view for the selected state
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
    [super dealloc];
}

@end
