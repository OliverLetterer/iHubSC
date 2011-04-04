//
//  UICollapsingTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UICollapsingAndSpinningTableViewCell.h"


@implementation UICollapsingAndSpinningTableViewCell

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
        self.disclosureIndicatorImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"]] autorelease];
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        [self.activityIndicatorView startAnimating];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorSelected.PNG"];
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorSelected.PNG"];
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_activityIndicatorView release];
    [_disclosureIndicatorImageView release];
    [super dealloc];
}

@end
