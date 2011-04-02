//
//  GHIssueFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueFeedItemTableViewCell.h"


@implementation GHIssueFeedItemTableViewCell

@synthesize gravatarImageView=_gravatarImageView, actorLabel=_actorLabel, statusLabel=_statusLabel, repositoryLabel=_repositoryLabel, activityIndicatorView=_activityIndicatorView;

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
#warning remove these @try-@catch structure, we currently need it because of an CALayerInvalidGeometry exception (CALayer position contains NaN: [nan 57])
    @try {
        [super layoutSubviews];
        _myContentView.frame = self.contentView.bounds;
    }
    @catch (NSException *exception) {
        
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabel.text = NSLocalizedString(@"Downloading ...", @"");
    self.actorLabel.text = nil;
    self.repositoryLabel.text = nil;
    self.gravatarImageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
    [self.activityIndicatorView stopAnimating];
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
    [_activityIndicatorView release];
    [super dealloc];
}

@end
