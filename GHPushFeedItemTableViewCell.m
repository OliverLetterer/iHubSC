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

@synthesize firstCommitLabel=_firstCommitLabel, secondCommitLabel=_secondCommitLabel;

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
        self.firstCommitLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78.0, 20.0, 222.0, 16.0)] autorelease];
        self.firstCommitLabel.numberOfLines = 2;
        self.firstCommitLabel.font = [UIFont systemFontOfSize:12.0];
        self.firstCommitLabel.highlightedTextColor = [UIColor whiteColor];
        self.firstCommitLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.firstCommitLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.firstCommitLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.firstCommitLabel];
        
        self.secondCommitLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78.0, 20.0, 222.0, 16.0)] autorelease];
        self.secondCommitLabel.numberOfLines = 2;
        self.secondCommitLabel.font = [UIFont systemFontOfSize:12.0];
        self.secondCommitLabel.highlightedTextColor = [UIColor whiteColor];
        self.secondCommitLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.secondCommitLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.secondCommitLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.secondCommitLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)layoutSubviews {
#warning remove these @try-@catch structure, we currently need it because of an CALayerInvalidGeometry exception (CALayer position contains NaN: [nan 57])    
    
    @try {
        [super layoutSubviews];
        
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
            secondCommitSize.height = [GHPushFeedItemTableViewCell maxCommitHeight];
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
    self.firstCommitLabel.text = nil;
    self.secondCommitLabel.text = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [_firstCommitLabel release];
    [_secondCommitLabel release];
    [super dealloc];
}

@end
