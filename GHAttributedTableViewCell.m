//
//  GHIssueTitleTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAttributedTableViewCell.h"



#define kUIActionSheetTagLongPressedLink        127386

@implementation GHAttributedTableViewCell
@synthesize attributedTextView=_attributedTextView;
@synthesize buttonDelegate=_buttonDelegate;
@synthesize attributedString=_attributedString, selectedAttributesString=_selectedAttributesString;
@synthesize selectedURL=_selectedURL;

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

+ (CGFloat)heightWithAttributedString:(NSAttributedString *)content inAttributedTextView:(DTAttributedTextView *)textView {
    if (!textView) {
        textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    }
    textView.attributedString = content;
    textView.frame = CGRectMake(0.0f, 0.0f, 222.0f, 10.0f);
    CGFloat height = textView.contentSize.height + 65.0f;
    CGFloat minimumHeight = [self height];
    
    return height < minimumHeight ? minimumHeight : height;
}

#pragma mark - Memory management


@end
