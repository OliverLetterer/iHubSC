//
//  GHCreateIssueTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateIssueTableViewCell.h"


@implementation GHCreateIssueTableViewCell

@synthesize titleTextField=_titleTextField, descriptionTextField=_descriptionTextField;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.titleTextField = [[UITextField alloc] init];
        self.titleTextField.font = [UIFont boldSystemFontOfSize:12.0];
        self.titleTextField.placeholder = NSLocalizedString(@"Repository title", @"");
        self.titleTextField.borderStyle = UITextBorderStyleBezel;
        [self.contentView addSubview:self.titleTextField];
        
        self.descriptionTextField = [[UITextView alloc] init];
        self.descriptionTextField.backgroundColor = [UIColor whiteColor];
        self.descriptionTextField.font = [UIFont systemFontOfSize:12.0];
        self.descriptionTextField.layer.borderColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
        self.descriptionTextField.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.descriptionTextField];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleTextField.frame = CGRectMake(70.0, 10.0, 233.0, 21.0);
    self.descriptionTextField.frame = CGRectMake(70.0, 39.0, 233.0, 150.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management


@end
