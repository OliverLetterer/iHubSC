//
//  GHCreateMilestoneTitleAndDescriptionTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateMilestoneTitleAndDescriptionTableViewCell.h"


@implementation GHCreateMilestoneTitleAndDescriptionTableViewCell

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectZero;
    CGRect frame = self.titleTextField.frame;
    frame.origin.x = 5.0f;
    frame.size.width = CGRectGetWidth(self.contentView.bounds) - 10.0f;
    self.titleTextField.frame = frame;
    
    frame = self.textView.frame;
    frame.origin.x = 5.0f;
    frame.size.width = CGRectGetWidth(self.contentView.bounds) - 10.0f;
    self.textView.frame = frame;
}

@end
