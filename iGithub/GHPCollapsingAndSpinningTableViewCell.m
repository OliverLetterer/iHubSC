//
//  GHPCollapsingAndSpinningTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCollapsingAndSpinningTableViewCell.h"


@implementation GHPCollapsingAndSpinningTableViewCell

@synthesize activityIndicatorView=_activityIndicatorView, disclosureIndicatorImageView=_disclosureIndicatorImageView;

#pragma mark - Initialization

- (void)setSpinning:(BOOL)spinning {
    _isSpinning = spinning;
    if (spinning) {
        self.accessoryView = self.activityIndicatorView;
    } else {
        self.accessoryView = self.disclosureIndicatorImageView;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.disclosureIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"]];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView startAnimating];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)setLoading:(BOOL)loading {
    [self setSpinning:loading];
}

- (void)setExpansionStyle:(UIExpansionStyle)style {
    self.accessoryView = self.disclosureIndicatorImageView;
    switch (style) {
        case UIExpansionStyleExpanded:
            self.accessoryView.transform = CGAffineTransformIdentity;
            break;
        case UIExpansionStyleCollapsed:
            self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            break;
            
        default:
            break;
    }
}

#pragma mark - Memory management


@end
