//
//  GHPSearchScopeTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPSearchScopeTableViewCell.h"


@implementation GHPSearchScopeTableViewCell

@synthesize delegate=_delegate;

#pragma mark - target actions

- (void)buttonClicked:(UIButton *)button {
    NSUInteger index = [_buttons indexOfObject:button];
    if (index == _currentSelectedButtonIndex) {
        return;
    }
    
    if (index != NSNotFound) {
        button.selected = YES;
        [_buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *theButton = obj;
            if (theButton != button) {
                theButton.selected = NO;
            }
        }];
        
        _currentSelectedButtonIndex = index;
        [self.delegate searchScopeTableViewCell:self didSelectButtonAtIndex:index];
    }
}

#pragma mark - Initialization

- (id)initWithButtonTitles:(NSArray *)buttonTitles reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _buttons = [[NSMutableArray arrayWithCapacity:buttonTitles.count] retain];
        
        [buttonTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = obj;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_buttons addObject:button];
            [self.contentView addSubview:button];
            
            if (idx == 0) {
                button.selected = YES;
            }
        }];
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
    
    CGFloat buttonWidth = CGRectGetWidth(self.contentView.bounds) / (CGFloat)_buttons.count;
    CGFloat buttonHeight = CGRectGetHeight(self.contentView.bounds);
    [_buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        button.frame = CGRectMake(buttonWidth*(CGFloat)idx, 0.0f, buttonWidth, buttonHeight);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - instance methods

- (NSString *)titleForButtonAtIndex:(NSUInteger)index {
    UIButton *button = [_buttons objectAtIndex:index];
    return button.currentTitle;
}

#pragma mark - Memory management

- (void)dealloc {
    [_buttons release];
    
    [super dealloc];
}

@end
