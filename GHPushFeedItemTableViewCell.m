//
//  GHPushFeedItemTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPushFeedItemTableViewCell.h"
#import "UITableViewCell+Background.h"

@implementation GHPushFeedItemTableViewCell

@synthesize gravatarImageView=_gravatarImageView, activityIndicatorView=_activityIndicatorView, titleLabel=_titleLabel, repositoryLabel=_repositoryLabel, firstCommitLabel=_firstCommitLabel, secondCommitLabel=_secondCommitLabel;

+ (UIFont *)commitFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (CGFloat)maxCommitHeight {
    return 35.0;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"GHPushFeedItemTableViewCellContentView" owner:self options:nil];
        [self.contentView addSubview:_myContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self setBackgroundShadowHeight:5.0];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self setBackgroundShadowHeight:5.0];
}

- (void)layoutSubviews {
#warning remove these @try-@catch structure, we currently need it because of an CALayerInvalidGeometry exception (CALayer position contains NaN: [nan 57])
    @try {
        [super layoutSubviews];
        _myContentView.frame = self.contentView.bounds;
        
        CGFloat commitHeight = 0.0;
        
        // update the first commit label
        CGSize firstCommitSize = [self.firstCommitLabel.text sizeWithFont:[GHPushFeedItemTableViewCell commitFont] 
                                                        constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                                            lineBreakMode:UILineBreakModeWordWrap];
        if (firstCommitSize.height > [GHPushFeedItemTableViewCell maxCommitHeight]) {
            firstCommitSize.height = [GHPushFeedItemTableViewCell maxCommitHeight];
        }
        commitHeight += firstCommitSize.height;
        CGRect firstCommitFrame = self.firstCommitLabel.frame;
        firstCommitFrame.size = firstCommitSize;
        self.firstCommitLabel.frame = firstCommitFrame;
        
        // update the second commit label
        CGRect secondCommitFrame = self.secondCommitLabel.frame;
        CGSize secondCommitSize = [self.secondCommitLabel.text sizeWithFont:[GHPushFeedItemTableViewCell commitFont] 
                                                          constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                                              lineBreakMode:UILineBreakModeWordWrap];
        if (secondCommitSize.height > [GHPushFeedItemTableViewCell maxCommitHeight]) {
            firstCommitSize.height = [GHPushFeedItemTableViewCell maxCommitHeight];
        }
        commitHeight += secondCommitSize.height;
        secondCommitFrame.origin.y = self.firstCommitLabel.frame.size.height + self.firstCommitLabel.frame.origin.y + 7.0;
        commitHeight += 7.0;
        secondCommitFrame.size = secondCommitSize;
        self.secondCommitLabel.frame = secondCommitFrame;
    }
    @catch (NSException *exception) {
        
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.gravatarImageView.image = nil;
    [self.activityIndicatorView stopAnimating];
    self.titleLabel.text = nil;
    self.repositoryLabel.text = nil;
    self.firstCommitLabel.text = nil;
    self.secondCommitLabel.text = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [_myContentView release];
    [_gravatarImageView release];
    [_activityIndicatorView release];
    [_titleLabel release];
    [_repositoryLabel release];
    [_firstCommitLabel release];
    [_secondCommitLabel release];
    [super dealloc];
}

@end
