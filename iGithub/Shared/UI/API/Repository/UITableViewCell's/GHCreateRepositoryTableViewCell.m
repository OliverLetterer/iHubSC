//
//  GHCreateRepositoryTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateRepositoryTableViewCell.h"


@implementation GHCreateRepositoryTableViewCell
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
    
    self.titleTextField.frame = CGRectMake(67.0, 10.0, 233.0, 21.0);
    self.descriptionTextField.frame = CGRectMake(67.0, 39.0, 233.0, 21.0);
    self.publicSwitch.frame = CGRectMake(206.0, 68.0, 94.0, 27.0);
    self.publicLabel.frame = CGRectMake(67.0, 71.0, 131.0, 21.0);
}

@end
