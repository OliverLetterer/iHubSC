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

#pragma mark - setters and getters

- (NSMutableArray *)lazyImageViews {
    if (!_lazyImageViews) {
        _lazyImageViews = [NSMutableArray array];
    }
    return _lazyImageViews;
}

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
	button.URL = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
	[button addGestureRecognizer:longPress];
	
	return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    if (attachment.contentType == DTTextAttachmentTypeImage) {
        NSURL *imageURL = attachment.contentURL;
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        
		if (attachment.contents) {
			imageView.image = attachment.contents;
		}
        
        // url for deferred loading
        imageView.url = imageURL;
        
        if (![self.lazyImageViews containsObject:imageView]) {
            [self.lazyImageViews addObject:imageView];
        }
        
		return imageView;
	}
    
    return nil;
}

#pragma mark - Height

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content {
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:content width:317.0f];
    
    CGSize size = [contentView sizeThatFits:CGSizeMake(349.0f, MAXFLOAT)];
    CGFloat height = size.height + 29.0f;
    
    return height + 29.0f;
}

#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    CGSize imageSize = size;
    NSURL *url = lazyImageView.url;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [_attributedTextView.layoutFrame textAttachmentsWithPredicate:pred]) {
		oneAttachment.originalSize = imageSize;
		
        if (imageSize.width > 222.0f) {
            CGFloat scale = 222.0f / imageSize.width;
            imageSize.width *= scale;
            imageSize.height *= scale;
        }
        oneAttachment.displaySize = imageSize;
	}
	
	// redo layout
	// here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
	[_attributedTextView relayoutText];
    
    [self.buttonDelegate issueInfoTableViewCellDidChangeBounds:self];
}

#pragma mark - Memory management

- (void)dealloc {
    [_lazyImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DTLazyImageView *imageView = obj;
        if (imageView.delegate == self) {
            imageView.delegate = nil;
        }
    }];
}

@end
