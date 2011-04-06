//
//  GHFeedItemWithDescriptionTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UITableViewCell+Background.h"

@implementation GHFeedItemWithDescriptionTableViewCell

@synthesize descriptionLabel=_descriptionLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78.0, 20.0, 222.0, 21.0)] autorelease];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.font = [UIFont systemFontOfSize:12.0];
        self.descriptionLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.descriptionLabel.highlightedTextColor = [UIColor whiteColor];
        self.descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
        self.descriptionLabel.text = NSLocalizedString(@"Downloading ...", @"");
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.descriptionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.descriptionLabel.frame = CGRectMake(78.0, 15.0, 222.0, self.contentView.bounds.size.height - 50.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.descriptionLabel.text = NSLocalizedString(@"Downloading ...", @"");
}

+ (CGFloat)height {
    return 71.0;
}

#pragma mark - Memory management

- (void)dealloc {
    [_descriptionLabel release];
    [super dealloc];
}

@end
