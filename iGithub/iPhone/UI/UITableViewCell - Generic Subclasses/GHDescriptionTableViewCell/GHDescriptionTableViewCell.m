//
//  GHFeedItemWithDescriptionTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDescriptionTableViewCell.h"

@implementation GHDescriptionTableViewCell
@synthesize descriptionLabel=_descriptionLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.font = [UIFont systemFontOfSize:13.0f];
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
    
    CGFloat offsetY = CGRectGetMinY(self.textLabel.frame) + CGRectGetHeight(self.textLabel.frame) + 2.0f;
    
    CGSize newSize = CGSizeZero;
    if (self.descriptionLabel.text) {
        newSize = [self.descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] 
                                         constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                             lineBreakMode:UILineBreakModeWordWrap];
    }
    
    self.descriptionLabel.frame = CGRectMake(78.0, offsetY, 222.0, newSize.height);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.descriptionLabel.text = NSLocalizedString(@"Downloading ...", @"");
}

+ (CGFloat)height {
    return 71.0f;
}

+ (CGFloat)heightWithContent:(NSString *)content {
    CGFloat minHeight = [self height];
    
    if (!content) {
        return minHeight;
    }
    CGSize newSize = [content sizeWithFont:[UIFont systemFontOfSize:13.0f] 
                         constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                             lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = newSize.height < 21.0f ? 21.0f : newSize.height;
    height += 50.0f;
    
    return height < minHeight ? minHeight : height;
}

@end
