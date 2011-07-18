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

#warning follow event on Owners news feed should to to user and not repo

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.attributedTextView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
        self.attributedTextView.backgroundColor = [UIColor clearColor];
        self.attributedTextView.textDelegate = self;
        self.attributedTextView.alwaysBounceVertical = NO;
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
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Target actions

- (void)linkButtonClicked:(DTLinkButton *)sender {
    [self.buttonDelegate issueInfoTableViewCell:self receivedClickForButton:sender];
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
	DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:frame] autorelease];
	button.url = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.guid = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
//	UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)] autorelease];
//	[button addGestureRecognizer:longPress];
	
	return button;
}

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView {
    if (!textView) {
        textView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
    }
    textView.attributedString = content;
    textView.frame = CGRectMake(0.0f, 0.0f, 349.0f, 10.0f);
    return textView.contentSize.height + 29.0f;
}

#pragma mark - Memory management

- (void)dealloc {
    [_attributedTextView release];
    
    [super dealloc];
}

@end
