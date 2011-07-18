//
//  GHPIssueCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssueCommentTableViewCell.h"


@implementation GHPIssueCommentTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;

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
    self.attributedTextView.frame = CGRectMake(76.0f, 31.0f, CGRectGetWidth(self.contentView.bounds) - 76.0f, CGRectGetHeight(self.contentView.bounds) - 31.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Target actions

- (void)linkButtonClicked:(DTLinkButton *)sender {
    [self.buttonDelegate commentTableViewCell:self receivedClickForButton:sender];
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.buttonDelegate commentTableViewCell:self longPressRecognizedForButton:(DTLinkButton *)recognizer.view];
    }
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
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)] autorelease];
	[button addGestureRecognizer:longPress];
	
	return button;
}

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView {
    if (!textView) {
        textView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
    }
    textView.attributedString = content;
    textView.frame = CGRectMake(0.0f, 0.0f, 317.0f, 10.0f);
    
    CGFloat height = textView.contentSize.height + 41.0f;
    if (height < 80.0f) {
        height = 80.0f;
    }
    
    return height;
}

#pragma mark - Memory management

- (void)dealloc {
    [_attributedTextView release];
    
    [super dealloc];
}

@end
