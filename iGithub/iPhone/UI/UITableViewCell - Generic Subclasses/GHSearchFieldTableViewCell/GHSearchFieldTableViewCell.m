//
//  GHSearchFieldTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 03.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSearchFieldTableViewCell.h"
#import "UIColor+GithubUI.h"

CGFloat const kGHSearchFieldTableViewCellHeight = 44.0f;

@implementation GHSearchFieldTableViewCell
@synthesize searchBar=_searchBar;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.tintColor = [UIColor defaultNavigationBarTintColor];
        [self addSubview:_searchBar];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _searchBar.frame = self.bounds;
}

@end
