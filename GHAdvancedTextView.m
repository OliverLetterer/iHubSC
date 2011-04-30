//
//  GHAdvancedTextView.m
//  iGithub
//
//  Created by Oliver Letterer on 23.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAdvancedTextView.h"


@implementation GHAdvancedTextView

@synthesize coreTextView=_coreTextView;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Memory management

- (void)dealloc {
    [_coreTextView release];
    
    [super dealloc];
}

@end
