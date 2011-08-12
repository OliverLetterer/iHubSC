//
//  GHIssueTitleTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAttributedTableViewCell.h"
#import "UIImage+Resize.h"

#define kUIActionSheetTagLongPressedLink        127386

@implementation GHAttributedTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;
@synthesize attributedString=_attributedString, selectedAttributesString=_selectedAttributesString;
@synthesize selectedURL=_selectedURL;

#pragma mark - setters and getters

- (NSMutableArray *)lazyImageViews {
    if (!_lazyImageViews) {
        _lazyImageViews = [NSMutableArray array];
    }
    return _lazyImageViews;
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    if(attributedString != _attributedString) {
        _attributedString = attributedString;
        [_attributedTextView removeAllCustomViews];
    }
}

- (void)setSelectedAttributesString:(NSAttributedString *)selectedAttributesString {
    if (selectedAttributesString != _selectedAttributesString) {
        _selectedAttributesString = selectedAttributesString;
        [_attributedTextView removeAllCustomViews];
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.descriptionLabel.text = nil;
        self.attributedTextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero];
        self.attributedTextView.backgroundColor = [UIColor clearColor];
        self.attributedTextView.delegate = self;
        [self.contentView addSubview:self.attributedTextView];
    }
    return self;
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
    
    [self.buttonDelegate attributedTableViewCellDidChangeBounds:self];
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    self.attributedTextView.frame = CGRectMake(78.0f, 21.0f, 222.0f, self.contentView.bounds.size.height - 48.0f);
    [self.attributedTextView layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.descriptionLabel.text = nil;
}

#pragma mark - Target actions

- (void)linkButtonClicked:(DTLinkButton *)sender {
    [self.buttonDelegate attributedTableViewCell:self receivedClickForButton:sender];
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer {
    DTLinkButton *button = (DTLinkButton *)recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if ([self.buttonDelegate respondsToSelector:@selector(attributedTableViewCell:longPressRecognizedForButton:)]) {
            [self.buttonDelegate attributedTableViewCell:self longPressRecognizedForButton:button];
        } else {
            self.selectedURL = button.url;
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            
            sheet.title = button.url.absoluteString;
            [sheet addButtonWithTitle:NSLocalizedString(@"View in Safari", @"")];
            [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
            sheet.cancelButtonIndex = 1;
            sheet.delegate = self;
            sheet.tag = kUIActionSheetTagLongPressedLink;
            
            [sheet showInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagLongPressedLink) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {
        }
        
        if ([title isEqualToString:NSLocalizedString(@"View in Safari", @"")]) {
            [[UIApplication sharedApplication] openURL:self.selectedURL];
        }
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
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:content width:222.0f];
    CGFloat minimumHeight = [self height];
    
    CGSize size = [contentView sizeThatFits:CGSizeMake(222.0f, MAXFLOAT)];
    CGFloat height = size.height + 65.0f;
    
    return height < minimumHeight ? minimumHeight : height;
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
