//
//  UITableViewCellWithLinearGradientBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewCellWithLinearGradientBackgroundView.h"
#import "GHLinearGradientBackgroundView.h"
#import "GHLinearGradientSelectedBackgroundView.h"

@implementation GHTableViewCellWithLinearGradientBackgroundView
@synthesize linearBackgroundView=_linearBackgroundView, selectedLinearGradientView=_selectedLinearGradientView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        GHLinearGradientBackgroundView *backgroundView = [[GHLinearGradientBackgroundView alloc] initWithFrame:CGRectZero];
        self.backgroundView = backgroundView;
        _linearBackgroundView = backgroundView;
        
        GHLinearGradientSelectedBackgroundView *selectedBackgroundView = [[GHLinearGradientSelectedBackgroundView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = selectedBackgroundView;
        _selectedLinearGradientView = selectedBackgroundView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectInset(self.imageView.frame, 3.0f, 3.0f);
}

@end
