//
//  GHPIssueCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 18.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPAttributedTableViewCell.h"





#define kUIActionSheetTagLongPressedLink    172637

@implementation GHPAttributedTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;
@synthesize selectedURL=_selectedURL;

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.attributedTextView.frame = CGRectMake(76.0f, 31.0f, CGRectGetWidth(self.contentView.bounds) - 76.0f, CGRectGetHeight(self.contentView.bounds) - 31.0f);
    [self.attributedTextView layoutSubviews];
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
            self.selectedURL = button.URL;
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            
            sheet.title = button.URL.absoluteString;
            [sheet addButtonWithTitle:NSLocalizedString(@"View in Safari", @"")];
            sheet.delegate = self;
            sheet.tag = kUIActionSheetTagLongPressedLink;
            
            UIView *viewToShowIn = [UIApplication sharedApplication].delegate.window.rootViewController.view;
            [sheet showFromRect:[button convertRect:button.bounds toView:viewToShowIn] inView:viewToShowIn animated:YES];
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

#pragma mark - height

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content {
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:content width:317.0f];
    CGFloat minimumHeight = 80.0f;
    
    CGSize size = [contentView sizeThatFits:CGSizeMake(222.0f, MAXFLOAT)];
    CGFloat height = size.height + 41.0f;
    
    return height < minimumHeight ? minimumHeight : height;
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
