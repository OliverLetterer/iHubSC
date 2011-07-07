//
//  GHPInfoTableViewCellDelegate.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPInfoTableViewCell.h"
#import "UIImage+Resize.h"


@implementation GHPInfoTableViewCell

@synthesize actionButton=_actionButton, activityIndicatorView=_activityIndicatorView, delegate=_delegate;

- (void)actionButtonClicked:(UIButton *)button {
    [self.delegate infoTableViewCellActionButtonClicked:self];
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.contentMode = UIViewContentModeTop;
        self.detailTextLabel.shadowColor = [UIColor whiteColor];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize size = CGSizeMake(37.0f, 25.0f);
        UIImage *image = [[UIImage imageNamed:@"UIBarButtonSystemItemAction.png"] resizedImage:size 
                                                                          interpolationQuality:kCGInterpolationHigh];
        [self.actionButton setImage:image forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionButton];
        
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.activityIndicatorView.hidesWhenStopped = YES;
        [self.activityIndicatorView stopAnimating];
        [self.contentView addSubview:self.activityIndicatorView];
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
    
    self.imageView.frame = CGRectMake(0.0f, 0.0f, 56.0f, 56.0f);
    self.textLabel.frame = CGRectMake(64.0f, 0.0f, CGRectGetWidth(self.contentView.bounds)-64.0f - 37.0f, 21.0f);
    self.detailTextLabel.frame = CGRectMake(64.0f, 29.0f, CGRectGetWidth(self.contentView.bounds)-64.0f, CGRectGetHeight(self.contentView.bounds)-29.0f);
    [self.detailTextLabel sizeToFit];
    self.actionButton.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds)-37.0f, 0.0f, 37.0f, 25.0f);
    self.activityIndicatorView.center = self.actionButton.center;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

+ (CGFloat)heightWithContent:(NSString *)content {
    if (!content) {
        return UITableViewAutomaticDimension;
    }
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(349.0f, CGFLOAT_MAX) 
                          lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + 29.0f;
}

#pragma mark - Memory management

- (void)dealloc {
    [_actionButton release];
    [_activityIndicatorView release];
    
    [super dealloc];
}

@end
