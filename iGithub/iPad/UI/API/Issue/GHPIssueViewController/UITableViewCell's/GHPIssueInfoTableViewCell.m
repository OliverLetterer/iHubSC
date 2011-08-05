//
//  GHPIssueInfoTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssueInfoTableViewCell.h"

@implementation GHPIssueInfoTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.attributedTextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero];
        self.attributedTextView.backgroundColor = [UIColor clearColor];
        self.attributedTextView.delegate = self;
        [self.contentView addSubview:self.attributedTextView];
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
    self.attributedTextView.frame = CGRectMake(64.0f, 29.0f, CGRectGetWidth(self.contentView.bounds)-64.0f, CGRectGetHeight(self.contentView.bounds)-29.0f);
    [self.attributedTextView layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Target actions

- (void)linkButtonClicked:(DTLinkButton *)sender {
    [self.buttonDelegate issueInfoTableViewCell:self receivedClickForButton:sender];
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.buttonDelegate issueInfoTableViewCell:self longPressRecognizedForButton:(DTLinkButton *)recognizer.view];
    }
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.url = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.guid = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
	[button addGestureRecognizer:longPress];
	
	return button;
}

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content {
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:content width:317.0f];
    
    CGSize size = [contentView sizeThatFits:CGSizeMake(349.0f, MAXFLOAT)];
    CGFloat height = size.height + 29.0f;
    
    return height + 29.0f;
}

#pragma mark - Memory management


@end
