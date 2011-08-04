//
//  GHPCreateRepositoryTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCreateRepositoryTableViewCell.h"


@implementation GHPCreateRepositoryTableViewCell
@synthesize publicLabel=_publicLabel, publicSwitch=_publicSwitch, titleTextField=_titleTextField, descriptionTextField=_descriptionTextField;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.titleTextField = [[UITextField alloc] init];
        self.titleTextField.font = [UIFont boldSystemFontOfSize:12.0];
        self.titleTextField.placeholder = NSLocalizedString(@"Repository title", @"");
        self.titleTextField.borderStyle = UITextBorderStyleBezel;
        self.titleTextField.textColor = [UIColor blackColor];
        self.titleTextField.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleTextField];
        
        self.descriptionTextField = [[UITextField alloc] init];
        self.descriptionTextField.font = [UIFont boldSystemFontOfSize:12.0];
        self.descriptionTextField.placeholder = NSLocalizedString(@"Repository description", @"");
        self.descriptionTextField.borderStyle = UITextBorderStyleBezel;
        self.descriptionTextField.textColor = [UIColor blackColor];
        self.descriptionTextField.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.descriptionTextField];
        
        self.publicSwitch = [[UISwitch alloc] init];
        [self.publicSwitch setOn:YES];
        [self.contentView addSubview:self.publicSwitch];
        
        self.publicLabel = [[UILabel alloc] init];
        self.publicLabel.text = NSLocalizedString(@"Public", @"");
        self.publicLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.publicLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5.0f, 5.0f, 64.0f, 63.0f);
    
    self.titleTextField.frame = CGRectMake(70.0f, 10.0f, CGRectGetWidth(self.contentView.bounds) - 75.0f, 21.0f);
    self.descriptionTextField.frame = CGRectMake(70.0f, 39.0f, CGRectGetWidth(self.contentView.bounds) - 75.0f, 21.0f);
    self.publicSwitch.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 100.0f, 68.0f, 94.0f, 27.0f);
    self.publicLabel.frame = CGRectMake(70.0f, 71.0f, 131.0f, 21.0f);
}

@end
