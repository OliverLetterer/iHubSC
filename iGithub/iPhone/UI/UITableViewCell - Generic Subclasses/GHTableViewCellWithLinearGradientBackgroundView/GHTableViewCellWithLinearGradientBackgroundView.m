//
//  UITableViewCellWithLinearGradientBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewCellWithLinearGradientBackgroundView.h"
#import "UITableViewCell+Background.h"
#import "GHLinearGradientBackgroundView.h"

@implementation GHTableViewCellWithLinearGradientBackgroundView

@synthesize linearBackgroundView=_linearBackgroundView;

- (UIColor *)defaultShadowColor {
    return [UIColor whiteColor];
}

- (UIColor *)shadowColorForView:(UIView *)view {
    return self.defaultShadowColor;
}

- (CGSize)defaultShadowOffset {
    return CGSizeMake(-1.0f, 1.0f);
}

- (CGSize)shadowOffsetForView:(UIView *)view {
    return self.defaultShadowOffset;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        GHLinearGradientBackgroundView *backgroundView = [[GHLinearGradientBackgroundView alloc] initWithFrame:self.bounds];
        self.backgroundView = backgroundView;
        _linearBackgroundView = backgroundView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setBackgroundShadowHeight:5.0];
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        if ([view respondsToSelector:@selector(setShadowColor:)] && (self.selectionStyle != UITableViewCellSelectionStyleNone || !selected)) {
            [obj setShadowColor: !selected ? [self shadowColorForView:view] : nil ];
        }
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setBackgroundShadowHeight:5.0];
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        if ([view respondsToSelector:@selector(setShadowColor:)] && (self.selectionStyle != UITableViewCellSelectionStyleNone || !highlighted)) {
            [obj setShadowColor: !highlighted ? [self shadowColorForView:view] : nil ];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management


@end
