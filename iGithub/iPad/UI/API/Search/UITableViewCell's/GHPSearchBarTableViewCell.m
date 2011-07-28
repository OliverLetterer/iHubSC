//
//  GHPSearchBarTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPSearchBarTableViewCell.h"


@implementation GHPSearchBarTableViewCell

@synthesize searchBar=_searchBar;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.searchBar];
        
        for (UIView *subview in self.searchBar.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subview removeFromSuperview];
                break;
            }
        }
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
    self.searchBar.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management


@end
