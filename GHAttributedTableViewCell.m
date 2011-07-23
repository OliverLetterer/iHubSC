//
//  GHIssueTitleTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAttributedTableViewCell.h"


@implementation GHAttributedTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;
@synthesize attributedString=_attributedString, selectedAttributesString=_selectedAttributesString;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.descriptionLabel.text = nil;
        self.attributedTextView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
        self.attributedTextView.backgroundColor = [UIColor clearColor];
        self.attributedTextView.textDelegate = self;
        self.attributedTextView.alwaysBounceVertical = NO;
        self.attributedTextView.scrollsToTop = NO;
        [self.contentView addSubview:self.attributedTextView];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.attributedTextView.attributedString = self.selectedAttributesString;
    } else {
        self.attributedTextView.attributedString = self.attributedString;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.attributedTextView.attributedString = self.selectedAttributesString;
    } else {
        self.attributedTextView.attributedString = self.attributedString;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.attributedTextView.frame = CGRectMake(78.0, 21.0, 222.0, self.contentView.bounds.size.height - 48.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.descriptionLabel.text = nil;
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
    textView.frame = CGRectMake(0.0f, 0.0f, 222.0f, 10.0f);
    return textView.contentSize.height + 65.0f;
}

#pragma mark - Memory management

- (void)dealloc {
    [_attributedTextView release];
    [_attributedString release]; 
    [_selectedAttributesString release];
    
    [super dealloc];
}

@end
